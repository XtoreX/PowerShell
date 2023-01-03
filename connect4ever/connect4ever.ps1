# Auto-Change-Gateway en un Servidor sin DHCP
# Revisión : 2022-12/20

# La idea es poder cambiar entre 2 Gateways, el principal y el secundario, 
# de esta manera minimizamos el tiempo de desconexión de nuestro servidor.

# Desactivamos todos los mensajes de información y similares
$Global:ProgressPreference = 'SilentlyContinue'

# Limpiamos la Consola
Clear-Host
 
# Valores para el Servidor
$cfgIP     = "192.168.0.250"                        # IP del Servidor           : Comprobación de Seguridad
$cfgMask   = 24                                     # Máscara de Subred         : 255.255.255.0
$cfgGwy    = @("192.168.0.1", "192.168.0.2")        # IPs de Puertas de Enlace  : (Principal, Secundaria)
$cfgDNS    = @("208.67.222.222", "208.67.220.220")	# IPs Servidores DNS        : (Principal, Secundario)
$cfgIPType = "IPv4"                                 # Tipo de Conexión          : IPv4, no modificamos la IPv6
$adapName  = "adapName"                             # Nombre del Adaptador      : "Ethernet", ...

# Variables para las esperas
$waitGWOK  = 2257                                   # Espera si ACTIVE          : 37 Minutos y 37 segundos
$waitGWKO  = 37                                     # Espera si INACTIVE        : 37 segundos

# Ejecución eterna
while ($true)
 {
  # Seleccionamos el adaptador por su nombre
  $adapObj = Get-NetAdapter | ? {$_.Name -eq $adapName}
  $actIP = $(($adapObj | Get-NetIPConfiguration).IPv4Address.IPAddress)
  $actGW = $(($adapObj | Get-NetIPConfiguration).IPv4DefaultGateway.NextHop)
  # Verificamos que la IP sea la Definida
  if ($actIP -eq $cfgIP)
   {
    if ($actGW -eq $cfgGwy[0])
     {
      #if ((Test-NetConnection -DiagnoseRouting -InformationLevel Quiet -WarningAction SilentlyContinue -ErrorAction SilentlyContinue).PingSucceeded)
      #if ((Test-NetConnection -DiagnoseRouting -InformationLevel Quiet -WarningAction SilentlyContinue -ErrorAction SilentlyContinue).RouteDiagnosticsSucceeded)
      if ((Test-NetConnection -DiagnoseRouting).RouteDiagnosticsSucceeded)
       {
        echo "TM: $(Get-Date -Format 'yyyyMMdd HHmmss'), IP: $actIP, GW: $actGW, ST: ACTIVE"
        # Esperamos para la siguiente comprobación
        Start-Sleep -Seconds $waitGWOK
       }
      else
       {
        echo "TM: $(Get-Date -Format 'yyyyMMdd HHmmss'), IP: $actIP, GW: $actGW, ST: INACTIVE"
        # Eliminamos los datos de la conexión
        $adapObj | Remove-NetIPAddress -AddressFamily $cfgIPType -Confirm:$false | Out-Null
        $adapObj | Remove-NetRoute -AddressFamily $cfgIPType -Confirm:$false | Out-Null
        # Establecemos los nuevos datos de la conexión
        $adapObj | New-NetIPAddress -AddressFamily $cfgIPType -IPAddress $cfgIP -PrefixLength $cfgMask -DefaultGateway $cfgGwy[1] | Out-Null
        $adapObj | Set-DnsClientServerAddress -ServerAddresses $cfgDNS | Out-Null
        # DEBUG MODE ON
        echo "TM: $(Get-Date -Format 'yyyyMMdd HHmmss'), IP: $actIP, GW: $actGW, ST: CHANGED"
       }
     }
    if ($actGW -eq $cfgGwy[1])
     {
      # DEBUG MODE ON
      echo "TM: $(Get-Date -Format 'yyyyMMdd HHmmss'), IP: $actIP, GW: $actGW, ST: ACTIVE"
      # Esperamos para cambiar a la GW Principal
      Start-Sleep -Seconds $waitGWOK
      # Eliminamos los datos de la conexión
      $adapObj | Remove-NetIPAddress -AddressFamily $cfgIPType -Confirm:$false | Out-Null
      $adapObj | Remove-NetRoute -AddressFamily $cfgIPType -Confirm:$false | Out-Null
      # Establecemos los nuevos datos de la conexión
      $adapObj | New-NetIPAddress -AddressFamily $cfgIPType -IPAddress $cfgIP -PrefixLength $cfgMask -DefaultGateway $cfgGwy[0] | Out-Null
      $adapObj | Set-DnsClientServerAddress -ServerAddresses $cfgDNS | Out-Null
      # DEBUG MODE ON
      echo "TM: $(Get-Date -Format 'yyyyMMdd HHmmss'), IP: $actIP, GW: $actGW[0], ST: CHANGED"
     }
   }
  else
   {echo "IP : KO"}
  # Esperamos para la siguiente comprobación
  Start-Sleep -Seconds $waitGWKO
 }
