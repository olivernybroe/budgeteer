<script lang="ts">
    export let income : number
    export let avgIncome : number;
    export let numberFormatter : Intl.NumberFormat;
</script>

<div class="text-mantis-500">
    <h3 class="text-sm">Income</h3>
    <p class="text-2xl">+{numberFormatter.format(income)}</p>
    <p class="text-xs">Avg.: {numberFormatter.format(avgIncome)}</p>
</div>