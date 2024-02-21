export class MonthUsage {
    year: number;
    month: number;
    spend: number;
    earn: number;

    constructor(year: number, month: number, earn: number, spend: number) {
        this.year = year;
        this.month = month;
        this.spend = spend;
        this.earn = earn;
    }
}