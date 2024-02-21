<script>
    let date = new Date();
    const monthNames = [ "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December" ];

    // Create a list with the last 30 years and the next 30 years
    const years = Array.from({length: 60}, (v, k) => k + date.getFullYear() - 30);



</script>

<select class="appearance-none bg-blue-950 text-blue-100">
    {#each monthNames as monthName, index}
        <option selected={date.getMonth() === index } value={index}>{monthName.substring(0,3)}</option>
    {/each}
</select>

<select class="appearance-none bg-blue-950 text-blue-100">
    {#each years as year}
        <option selected={date.getFullYear() === year } value={year}>{year}</option>
    {/each}
</select>