$totalNumOfTie = 0
$totalNumOfGenetic = 0
$totalNumOfGreedy = 0

$iteration = 1
for($numOfItems = 10; $numOfItems -le 90; $numOfItems+=8) {

    Write-Host ("`r`nTest " + $iteration + ", NumberOfItems = " + $numOfItems + "`r`n")

    .\CreateDataFile.ps1 -numOfItems $numOfItems
    $numOfTie = 0
    $numOfGenetic = 0
    $numOfGreedy = 0
    $precentOfCapacity = ((.\Get-Capacity.ps1 .\GenaratedData.txt)/100)
    for($bagSize = $precentOfCapacity; $bagSize -le $precentOfCapacity*100; $bagSize += $precentOfCapacity) {
        $greedy = [int]([string]((.\Greedy.ps1 .\GenaratedData.txt -bagSize $bagSize) | sls "price")).Split(" ")[3]
        $genetic = [int]([string]((.\Genetic.ps1 .\GenaratedData.txt -bagSize $bagSize -SizeOfPopulation 25 -NumOfGenerations 75) | sls "price")).Split(" ")[3]

        if($genetic -eq $greedy) {
            $numOfTie++
            $totalNumOfTie++
            Write-Host ("Tie, Bag size = " + ([int]$bagSize) + ", Price = " + $genetic) -ForegroundColor Yellow -BackgroundColor Black
        }
        else {
            if($greedy -gt $genetic) {
                $numOfGreedy++
                $totalNumOfGreedy++
                Write-Host ("Greedy won, Bag size = " + ([int]$bagSize) + ", Price = " + $greedy) -ForegroundColor Red -BackgroundColor Black
            }
            else {
                $numOfGenetic++
                $totalNumOfGenetic++
                Write-Host ("Genetic won, Bag size = " + ([int]$bagSize) + ", Price = " + $genetic) -ForegroundColor Green -BackgroundColor Black
            }
        }
    }
    Write-Host ""
    Write-Host ("Tie: " + $numOfTie + " Times") -ForegroundColor Yellow -BackgroundColor Black
    Write-Host ("Genetic: " + $numOfGenetic + " Times") -ForegroundColor Green -BackgroundColor Black
    Write-Host ("Greedy: " + $numOfGreedy + " Times") -ForegroundColor Red -BackgroundColor Black
    Write-Host ""

}

$totalTests = $totalNumOfTie + $totalNumOfGenetic + $totalNumOfGreedy

Write-Host ""
Write-Host ("Present of tie: " + [System.Math]::Round(($totalNumOfTie/$totalTests),2) + "%") -ForegroundColor Yellow -BackgroundColor Black
Write-Host ("Present of genetic: " + [System.Math]::Round(($totalNumOfGenetic/$totalTests),2) + "%") -ForegroundColor Green -BackgroundColor Black
Write-Host ("Present of greedy: " + [System.Math]::Round(($totalNumOfGreedy/$totalTests),2) + "%") -ForegroundColor Red -BackgroundColor Black
Write-Host ""