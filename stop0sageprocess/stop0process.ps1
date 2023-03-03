# Stop-Older-Process en un Servidor Windows con multiples conexiones RPD
# Revisión : 2023-03-02

# Matamos los procesos que tienen más de 1 día de los usuarios definidos

# Desactivamos todos los mensajes de información y similares
$Global:ProgressPreference = 'SilentlyContinue'
# Desactivamos todos los mensajes de las excepciones
$ErrorActionPreference= 'SilentlyContinue'

Clear;

Write-Host "";
$day4host = Get-Date;
$day4host;

$dom2ctrl = @("Dominio");
$usr2ctrl = @("Usuario_1", `
              "Usuario_2", `
              "Usuario_3", `
              "Usuario_4", `
              "Usuario_5"
             );

Write-Host "--------------------------------------------------------------------------------------";
foreach ($iDomain in $dom2ctrl)
 {
  $iResult = Get-WmiObject Win32_Process `
   | Where-Object -FilterScript {($_.GetOwner().Domain -eq $iDomain)}
  If ($iResult.Count -gt 0)
   {
    ForEach ($iUser in $usr2ctrl)
     {
      $iResult = Get-WmiObject Win32_Process `
       | Where-Object -FilterScript {($_.GetOwner().Domain -eq $iDomain) -and ($_.GetOwner().User -eq $iUser)} `
       | Select ProcessID, @{Name='iniTime';Expression={$_.ConvertToDateTime($_.CreationDate)}}, @{Name='usrName';Expression={$_.GetOwner().User}}, Name `
       | Sort-Object usrName, iniTime
      If ($iResult.Count -gt 0)
       {   
        ForEach ($iProcess in $iResult)
         {
          if((New-TimeSpan -Start $iProcess.iniTime -End $day4host).Days -ne 0)
           {
            Write-Host "  · Elimando : `"$($iProcess.Name.ToString())`" iniciado hace $((New-TimeSpan -Start $iProcess.iniTime -End $day4host).Days) dias" ;
            Stop-Process -Id $iProcess.ProcessID -Force;
           }
         }
       }
     }
   }
 }
Write-Host "--------------------------------------------------------------------------------------";
