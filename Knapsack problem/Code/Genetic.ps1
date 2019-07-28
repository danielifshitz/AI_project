
param([string]$DataFile=".\data.txt", [int]$bagSize=100, [int]$SizeOfPopulation=10, [int]$NumOfGenerations=100, [double]$MutationRate=0.5)

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

# Genetic Algorithm

function IsPossibleChromosome($Chromosome) {
    # True if Possible, False otherwize
    $SumCapacity = 0
    $index = 0
    $Chromosome | foreach {
        if($_ -eq 1) {
            $SumCapacity += $Items[$index].Volume
        }
        $index++
    }
    if($SumCapacity -le $bagSize) {
        return $true
    }
    else {
        return $false
    }
}

function AddGensToChromosome($Chromosome) {
    foreach($i in (0..$numOfItems)) {
        $index = Get-Random -Minimum 0 -Maximum ($numOfItems)
        if($Chromosome[$index] -eq 0){
            $Chromosome[$index] = 1
            if(-Not (IsPossibleChromosome $Chromosome)) {
                $Chromosome[$index] = 0
            }
        }
    }
}

function CreatePossibleChromosome {
    $Chromosome = [System.Collections.ArrayList]::new()
    foreach($i in (1..$numOfItems)) {
        $Chromosome.Add(0) | Out-Null
    }
    AddGensToChromosome $Chromosome
    return $Chromosome
}

function CreatePopulation() {
    #Return Random Population (solutions)
    $Population = [System.Collections.ArrayList]::new()
    foreach($i in (0..$SizeOfPopulation)) {
        $Population.Add((CreatePossibleChromosome)) | Out-Null
    }
    return ($population | sort {Fitness($_)} -Descending)[0..1]
}

function Fitness($Chromosome) {
    # Returns the value of the solution
    if(-Not (IsPossibleChromosome $Chromosome)) {
        return -1
    }
    $SumPrice = 0
    $index = 0
    $Chromosome | foreach {
        if($_ -eq 1) {
            $SumPrice += ($Items[$index].Price * $Items[$index].Volume)
        }
        $index++
    }
    return $SumPrice
}

function Mutation($Chromosome) {
    # Return a mutation of the chromosome
    $index = Get-Random -Minimum 0 -Maximum ($numOfItems)
    if($Chromosome[$index] -eq 1){
        $Chromosome[$index] = 0
        $index = Get-Random -Minimum 0 -Maximum ($numOfItems)
        #Try to add gen
        $index1 = Get-Random -Minimum 0 -Maximum ($numOfItems)
        $index2 = Get-Random -Minimum 0 -Maximum ($numOfItems)
        if($Chromosome[$index1] -eq 0){
            $Chromosome[$index1] = 1
            if(-Not (IsPossibleChromosome $Chromosome)) {
                $Chromosome[$index1] = 0
            }
        }
        if($Chromosome[$index2] -eq 0){
            $Chromosome[$index2] = 1
            if(-Not (IsPossibleChromosome $Chromosome)) {
                $Chromosome[$index2] = 0
            }
        }
    }
    else {
        $Chromosome[$index] = 1
        if(-Not (IsPossibleChromosome $Chromosome)) {
            $Chromosome[$index] = 0
        }
    }
}

function Crossover([System.Array]$Chromosome1, [System.Array]$Chromosome2) {
    $index = Get-Random -Minimum 0 -Maximum ($numOfItems - 1)
    $firstChild = ($Chromosome1[0..$index] + $Chromosome2[($index+1)..($numOfItems-1)])
    $secondChild = ($Chromosome2[0..$index] + $Chromosome1[($index+1)..($numOfItems-1)])
    return ($firstChild,$secondChild)
}

write ( "`r`nTotal time " + [int](Measure-Command {
$population = [System.Collections.ArrayList]::new((CreatePopulation))

foreach($i in (0..$NumOfGenerations)) {
    # First Crossover
    $Children = (Crossover $population[0] $population[1])
    if(IsPossibleChromosome $Children[0]) {
        $Probability = Get-Random -Minimum 0.0 -Maximum 1.0
        if($Probability -le $MutationRate) {
            Mutation $Children[0] | Out-Null
        }
        $population.Add($Children[0]) | Out-Null
    }
    if(IsPossibleChromosome $Children[1]) {
        $Probability = Get-Random -Minimum 0.0 -Maximum 1.0
        if($Probability -le $MutationRate) {
            Mutation $Children[1] | Out-Null
        }
        $population.Add($Children[1]) | Out-Null
    }

    # Second Crossover - with the Childrens
    $Children = (Crossover $Children[0] $Children[1])
    if(IsPossibleChromosome $Children[0]) {
        $Probability = Get-Random -Minimum 0.0 -Maximum 1.0
        if($Probability -le $MutationRate) {
            Mutation $Children[0] | Out-Null
        }
        $population.Add($Children[0]) | Out-Null
    }
    if(IsPossibleChromosome $Children[1]) {
        $Probability = Get-Random -Minimum 0.0 -Maximum 1.0
        if($Probability -le $MutationRate) {
            Mutation $Children[1] | Out-Null
        }
        $population.Add($Children[1]) | Out-Null
    }

    # Take two best Chromosomes
    while($population.Count -ne 2) {
        $population.Remove(($population | sort {Fitness($_)})[0]) | Out-Null
    }

    # Local minimum issue - kill one chromosome and add new one
    if((Fitness $population[0]) -eq (Fitness $population[1])) {
        $population.Remove(($population | sort {Fitness($_)})[0]) | Out-Null
        $population.Add((CreatePossibleChromosome)) | Out-Null
    }
}
}).TotalMilliseconds + " Milliseconds")

$ItemsTook = [System.Collections.ArrayList]::new()
$index = 0
$Chromosome = (($population | sort {Fitness($_)} -Descending)[0])
$Chromosome | foreach {
    if($_ -eq 1) {
        $ItemsTook.Add(($Items[$index])) | Out-Null
    }
    $index++
}

$ItemsTook | Format-Table

write ("Total price took " + (Fitness ($population | sort {Fitness($_)} -Descending)[0]))
write ""