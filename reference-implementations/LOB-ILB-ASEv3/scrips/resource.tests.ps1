param(
  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$ResourceLocation,

  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$WorkloadName,

  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$Environment,

  [Parameter(Mandatory)]
  [ValidateNotNullOrEmpty()]
  [string]$Suffix
)

$resourceSuffix = "$WorkloadName-$Environment-$ResourceLocation-$Suffix"

Describe "Network resources should be located in $ResourceLocation" {
    $resources = az resource list --resource-group "rg-networking-$resourceSuffix" | ConvertFrom-Json

    It "$($resource.location) is $ResourceLocation" -ForEach $resources {
        $_.location | Should -Be $ResourceLocation
    }               
}

Describe "Shared resources should be located in global or $ResourceLocation" {
    $resources = az resource list --resource-group "rg-shared-$resourceSuffix" | ConvertFrom-Json

    It "$($resource.location) is $ResourceLocation" -ForEach $resources {
      $_.location | Should -BeIn @('global', $ResourceLocation)
    }
}

Describe "ASE resources should be located in $ResourceLocation" {
    $resources = az resource list --resource-group "rg-ase-$resourceSuffix" | ConvertFrom-Json

    It "$($resource.location) is $ResourceLocation" -ForEach $resources {
      $_.location | Should -Be $ResourceLocation
    }
}

Describe "ASE should be ASEv3" {
  BeforeAll { 
      $resource = az resource show --name "ase-$resourceSuffix" --resource-group "rg-ase-$resourceSuffix" --resource-type "Microsoft.Web/hostingEnvironments" | ConvertFrom-Json
  }
  It "$($resource.kind) is ASEV3" {
      $resource.kind | Should -Be 'ASEV3'
  }               
}
