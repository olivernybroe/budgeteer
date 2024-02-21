<script lang="ts">
    import Overview from "./Overview.svelte";
    import MonthYearSelection from "./MonthSelection.svelte";
    import IncomeOverview from "./IncomeOverview.svelte";
    import SpendingOverview from "./SpendingOverview.svelte";
    import SpendingMonthly from "./MonthlyUsageBarChart.svelte";
    import {MonthUsage} from "../models/MonthUsage.js";

    const numberFormatter = Intl.NumberFormat("da-DK", {style: 'currency', currency: 'DKK'})
    const spendings = [
        new MonthUsage(2022, 7, 10000, 5000),
        new MonthUsage(2022, 8, 50000, 5000),
        new MonthUsage(2022, 9, 34000, 7600),
        new MonthUsage(2022, 10, 10000, 5000),
        new MonthUsage(2022, 11, 10000, 5000),
        new MonthUsage(2022, 12, 10000, 2000),
        new MonthUsage(2023, 1, 10000, 5000),
        new MonthUsage(2023, 2, 100, 5000),
        new MonthUsage(2023, 3, 10000, 5000),
        new MonthUsage(2023, 4, 10000, 5000),
    ];

</script>

<nav class="h-24 bg-blue-950 flex flex-row pt-4
">
    <div class="basis-1/4 pl-4">
        <MonthYearSelection/>
    </div>
    <div class="basis-1/6">
        <IncomeOverview income={5999} numberFormatter={numberFormatter} avgIncome={6500}/>
    </div>
    <div class="basis-1/6">
        <SpendingOverview spending={5999} numberFormatter={numberFormatter} avgSpending={6500}/>
    </div>
    <div class="basis-1/6">
        <Overview numberFormatter={numberFormatter} amount={10000}/>
    </div>
    <div class="basis-1/4">
        <SpendingMonthly numberFormatter={numberFormatter} spendings={spendings}/>
    </div>
</nav>
