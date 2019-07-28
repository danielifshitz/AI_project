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
write ("`r`nTotal time " + (Measure-Command {

$SolutionNumber = 1
$BestSolution = 0

# Run First Greedy

$bagSizeCopy = $bagSize
$ItemsCopy = [System.Collections.ArrayList]::new($Items)
$ItemsToTake = ($ItemsCopy | sort Price -Descending)
$ItemsTook1 = [System.Collections.ArrayList]::new()
$TotalPrice = 0
foreach($i in (1..$numOfItems)) {
    # Check if there is space for the most valueable item
    if($bagSizeCopy -lt ($ItemsToTake[0].Volume)) {
        $ItemsCopy.Remove($ItemsToTake[0])
    }
    else {
        $bagSizeCopy -= $ItemsToTake[0].Volume
        $num = $ItemsTook1.Add($ItemsToTake[0])
        $TotalPrice += ($ItemsToTake[0].Volume * $ItemsToTake[0].Price)
        $ItemsCopy.Remove($ItemsToTake[0])
    }
    $ItemsToTake = ($ItemsCopy | sort Price -Descending)
}

$BestSolution = $TotalPrice

# Run Second Greedy

$bagSizeCopy = $bagSize
$ItemsCopy = [System.Collections.ArrayList]::new($Items)
$ItemsToTake = ($ItemsCopy | sort {$_.Price * $_.Volume} -Descending)
$ItemsTook2 = [System.Collections.ArrayList]::new()
$TotalPrice = 0
foreach($i in (1..$numOfItems)) {
    # Check if there is space for the most valueable item
    if($bagSizeCopy -lt ($ItemsToTake[0].Volume)) {
        $ItemsCopy.Remove($ItemsToTake[0])
    }
    else {
        $bagSizeCopy -= $ItemsToTake[0].Volume
        $num = $ItemsTook2.Add($ItemsToTake[0])
        $TotalPrice += ($ItemsToTake[0].Volume * $ItemsToTake[0].Price)
        $ItemsCopy.Remove($ItemsToTake[0])
    }
    $ItemsToTake = ($ItemsCopy | sort {$_.Price * $_.Volume} -Descending)
}

if($BestSolution -lt $TotalPrice) {
    $BestSolution = $TotalPrice
    $SolutionNumber = 2
}

}).TotalMilliseconds + " Milliseconds")

# Final Results
write ("Best Greedy " + $SolutionNumber)
write ""
switch ( $SolutionNumber )
{
    1 { $ItemsTook1 | Format-Table }
    2 { $ItemsTook2 | Format-Table }
    3 { $ItemsTook3 | Format-Table }
}
write ("Total price took " + $BestSolution)
write ""