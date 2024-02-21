<script lang="ts">
    export let amount : number
    export let numberFormatter : Intl.NumberFormat;
</script>

<div>
    <h2 class="text-sm">Balance</h2>
    <h3 class="text-3xl">{numberFormatter.format(amount)}</h3>
</div>