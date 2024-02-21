<script lang="ts">
    import type {MonthUsage} from "../models/MonthUsage";

    export let spendings : MonthUsage[];
    let highestValue = spendings.reduce((prev, current) => {
        return prev > current.earn ? prev : current.earn;
    }, 0);
    export let numberFormatter : Intl.NumberFormat;
    const size = 50;
    const spacingBetweenMonths = size * 2 + 20;
    const spacing = 2;
    const monthNames = [ "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December" ];
</script>

<svg class="h-16" viewBox="0 0 {spendings.length * (spacingBetweenMonths + spacing + size) } 130">

    {#each spendings as spending, index}
        <rect fill="none" x={index * spacingBetweenMonths} y=0 height=100 width={size * 2}></rect>
        <rect class="fill-red-600 hover:fill-red-700" x={index * spacingBetweenMonths} y={100 - ((spending.earn / highestValue) * 100)} width={size} height={(spending.earn / highestValue) * 100} />
        <rect class="fill-mantis-500 hover:fill-mantis-600" x={index * spacingBetweenMonths + size + spacing} y={100 - ((spending.spend / highestValue) * 100)} width={size} height={(spending.spend / highestValue) * 100}/>
        <text class="fill-blue-300" font-size="26" y="123" x={index * spacingBetweenMonths + (size / 2)}>{monthNames[spending.month-1].substring(0,3)}</text>
    {/each}
</svg>
