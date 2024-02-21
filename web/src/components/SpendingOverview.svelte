<script lang="ts">
    export let spending : number
    export let avgSpending : number;
    export let numberFormatter : Intl.NumberFormat;
</script>

<div class="text-red-700">
    <h3 class="text-sm">Spending</h3>
    <p class="text-2xl">-{numberFormatter.format(spending)}</p>
    <p class="text-xs">Avg.: {numberFormatter.format(avgSpending)}</p>
</div>