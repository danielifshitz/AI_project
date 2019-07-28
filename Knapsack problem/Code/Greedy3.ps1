param([string]$DataFile=".\data.txt", [int]$bagSize)

if(-Not (gi $DataFile -ErrorAction SilentlyContinue).Exists) {
    write "Usage: main.exe [[-DataFile] <string>] [[-bagSize] <int>]"
    return
}

if($bagSize -eq 0) {
    write "Usage: main.exe [[-DataFile] <string>] [[-bagSize] <int>]"
    write "Bag size must be bigger than 0"
    return
}

[int]$numOfItems = (gc $DataFile).Split("`n").Count

$Items = [System.Collections.ArrayList]::new()

for($i=0; $i -lt $numOfItems; $i++) {
    $currentItem = (gc $DataFile).Split("`n")[$i].Split(" ")
    $num = $Items.Add([pscustomobject]@{
ItemName = $currentItem[0]
Volume = [int]$currentItem[1]
Price = [int]$currentItem[2]
})

}

write ""
write ("Bag Size = " + $bagSize)
$Items | sort Price | sort Volume -Descending | Format-Table
write "-------------------------------------------------"

$ItemsToTake = ($Items | sort Volume -Descending)
$ItemsTook = [System.Collections.ArrayList]::new()
$TotalPrice = 0
foreach($i in (1..$numOfItems)) {
    # Check if there is space for the most valueable item
    if($bagSize -lt ($ItemsToTake[0].Volume)) {
        write ("Drop " + ($ItemsToTake[0]).ItemName)
        write "-------------------------------------------------"
        $Items.Remove($ItemsToTake[0])
    }
    else {
        $bagSize -= $ItemsToTake[0].Volume
        write ("Took " + ($ItemsToTake[0]).ItemName)
        write ("Capacity left in bag = " + $bagSize)
        write "-------------------------------------------------"
        $num = $ItemsTook.Add($ItemsToTake[0])
        $TotalPrice += ($ItemsToTake[0].Volume * $ItemsToTake[0].Price)
        $Items.Remove($ItemsToTake[0])
    }
    $ItemsToTake = ($Items | sort Volume -Descending)
}

write ""
$ItemsTook | Format-Table
write ("Total price took: " + $TotalPrice)
write ("Capacity left in bag = " + $bagSize)
write ""