param([int]$numOfItems=20)

try {
    ni GenaratedData.txt -ErrorAction Stop | Out-Null
}
catch {
    rm GenaratedData.txt
    ni GenaratedData.txt | Out-Null
}

for($index = 0; $index -lt $numOfItems; $index++) {
    Add-Content -Value ("Item" + $index + " " + (Get-Random -Maximum 1000 -Minimum 1) + " " + (Get-Random -Maximum 15 -Minimum 1)) -Path GenaratedData.txt
}
