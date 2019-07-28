param([string]$DataFile=".\data.txt")

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

($Items | measure -Property Volume -Sum).Sum