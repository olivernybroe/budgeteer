bring cloud;
bring ex;
bring http;
bring vite;

enum Currency {
    DKK
}

struct Account {
    id: str;
    bankNumber: str;
    name: str;
    balance: num;
    currency: str;
}

struct Transaction {
    id: str;
    accountId: str;
    amount: num;
    description: str;
}

interface BankDataService {
    inflight getAccounts(): MutArray<Account>;
}

struct NordigenRequisitionsResponse {
    reference: str;
    accounts: Array<str>;
}

struct NordigenAccountDetails {
    currency: str;
    name: str;
    iban: str;
    resourceId: str;
}

struct NordigenAccountDetailsReponse {
    account: NordigenAccountDetails;
}

struct NordigenBalanceAmount {
    amount: str;
    currency: str;
}

struct NordigenBalance {
    balanceAmount: NordigenBalanceAmount;
    balanceType: str;
}

struct NordigenBalancesResponse {
    balances: Array<NordigenBalance>;
}

struct NordigenTransactionAmount {
    amount: str;
    currency: str;
}

struct NordigenTransaction {
    transactionId: str;
    remittanceInformationUnstructuredArray: Array<str>;
    transactionAmount: NordigenTransactionAmount;
}

struct NordigenTransactions {
    booked: Array<NordigenTransaction>;
    pending: Array<NordigenTransaction>;
}

struct NordigenTransactionsResponse {
    transactions: NordigenTransactions;
}

class Nordigen impl BankDataService {
    secretId: cloud.Secret;
    secretKey: cloud.Secret;
    accessTokenCache: ex.Redis;

    new() {
        this.secretId = new cloud.Secret(
            name: "nordigen-secret-id",
        ) as "Secret ID";

        this.secretKey = new cloud.Secret(
            name: "nordigen-secret-key",
        ) as "Secret Key";

        this.accessTokenCache = new ex.Redis() as "Access-Token-Cache";
    }

    inflight newAccessToken(): str {
        let options = http.RequestOptions {
            headers: Map<str> {
                "Content-Type" => "application/json",
            },
            body: Json.stringify({
                "secret_id": this.secretId.value(),
                "secret_key": this.secretKey.value(),
            })
        };

        let result = http.post("https://bankaccountdata.gocardless.com/api/v2/token/new/", options);
        assert(result.ok);

        return Json.parse(result.body).get("access").asStr();
    }

    inflight get(path: str): str {
        let var accessToken = this.accessTokenCache.get("nordigen-access-token");

        if accessToken == nil {
            let newToken = this.newAccessToken();
            this.accessTokenCache.set("nordigen-access-token", newToken);
            accessToken = newToken;
        }

        let options = http.RequestOptions {
            headers: Map<str> {
                "Authorization" => "Bearer {accessToken}"
            }
        };

        let result = http.get("https://bankaccountdata.gocardless.com/api/v2/{path}", options);
        log(result.url);
        assert(result.ok);

        return result.body;
    }

    pub inflight getAccounts(): MutArray<Account> {
        let result = this.get("requisitions/38b39dcf-b329-475f-af8b-7958714b2d49");

        let data = NordigenRequisitionsResponse.parseJson(result);

        let accounts = MutArray<Account>[];
        for accountId in data.accounts {
            accounts.push(this.getAccount(accountId));
        }
        return accounts;
    }

    inflight getAccount(accountId: str): Account {
        let detailsString = this.get("accounts/{accountId}/details");
        let details = NordigenAccountDetailsReponse.parseJson(detailsString);

        let balancesString = this.get("accounts/{accountId}/balances");
        let balances = NordigenBalancesResponse.parseJson(balancesString);
        let balance = balances.balances.at(0).balanceAmount.amount;

        return Account {
            id: accountId,
            bankNumber: details.account.resourceId,
            name: details.account.name,
            balance: num.fromStr(balance),
            currency: details.account.currency
        };
    }

    pub inflight getTransactions(accountId: str): MutArray<Transaction> {
        let result = this.get("accounts/{accountId}/transactions");

        let data = NordigenTransactionsResponse.parseJson(result);

        let transactions = MutArray<Transaction>[];
        for transaction in data.transactions.booked {
            transactions.push(Transaction {
                id: transaction.transactionId,
                accountId: accountId,
                amount: num.fromStr(transaction.transactionAmount.amount),
                description: transaction.remittanceInformationUnstructuredArray.at(0)
            });
        }
        return transactions;
    }
}

let bankService = new Nordigen();

// Update bank data every 4 hours
let bankUpdateScheduler = new cloud.Schedule(cron: "0 */4 * * ?") as "Bank Update Scheduler";

let accountsTable = new ex.Table(
    name: "accounts",
    primaryKey: "id",
    columns: {
        "bankNumber" => ex.ColumnType.STRING,
        "name" => ex.ColumnType.STRING,
        "balance" => ex.ColumnType.NUMBER,
        "currency" => ex.ColumnType.STRING,
    }
) as "accounts";

let transactionsTable = new ex.Table(
    name: "transactions",
    primaryKey: "id",
    columns: {
        "amount" => ex.ColumnType.NUMBER,
        "accountId" => ex.ColumnType.STRING,
        "description" => ex.ColumnType.STRING,
        "date" => ex.ColumnType.DATE,
    }
) as "transactions";

bankUpdateScheduler.onTick(inflight () => {
    let accounts = bankService.getAccounts();

    for account in accounts {
        let data = Json {
            "name": account.name,
            "bankNumber": account.bankNumber,
            "balance": account.balance,
            "currency": account.currency,
        };
        log("Updating account {account.id}");
        accountsTable.upsert(account.id, data);
    }
});

bankUpdateScheduler.onTick(inflight () => {
    for accountJson in accountsTable.list() {
        let account = Account.fromJson(accountJson);
        log("Updating transactions for account {account.id}");

        let transactions = bankService.getTransactions(account.id);

        for transaction in transactions {
            let data = Json {
                "amount": transaction.amount,
                "accountId": transaction.accountId,
                "description": transaction.description,
            };
            transactionsTable.upsert(transaction.id, data);
        }
    }
});


let api = new cloud.Api() as "API";

api.get("/transactions", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    return cloud.ApiResponse {
        status: 200,
        body: Json.stringify(transactionsTable.list())
    };
});

api.get("/accounts", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    return cloud.ApiResponse {
        status: 200,
        body: Json.stringify(accountsTable.list())
    };
});

api.get("/accounts/:id", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    let id = request.vars.get("id");

    return cloud.ApiResponse {
        status: 200,
        body: Json.stringify(accountsTable.get(id))
    };
});

api.get("/accounts/:id/transactions", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    let id = request.vars.get("id");

    let transactions = MutArray<Transaction>[];

    // TODO: Replace with a query when that is supported
    for transactionJson in transactionsTable.list() {
        let transaction = Transaction.fromJson(transactionJson);
        if (transaction.accountId == id) {
            transactions.push(transaction);
        }
    }

    return cloud.ApiResponse {
        status: 200,
        body: Json.stringify(transactions)
    };
});

let website = new vite.Vite(
    root: "../web",
    publicEnv: {
        API_URL: api.url,
    },
);
