; Versión modular, con configuración externa
#NoTrayIcon
#SingleInstance force
#Persistent
SetBatchLines, -1
DetectHiddenWindows, On
SetWorkingDir, %A_ScriptDir%

; ===== CONFIGURACIÓN =====
settingsFile := A_ScriptDir . "\drv\settings.ini"

; Valores por defecto
idleMinutes := 5
backupLogs := 1
saveCSV := 1
startHidden := 1
notify := 0
logFolder := "drv\\logs"
jsonFolder := "drv\\json"
cacheFolder := "drv\\.cache"
csvFile := "Scans.csv"
configSource := "DEFAULT"

; Leer desde settings.ini si existe
if FileExist(settingsFile) {
    IniRead, idleMinutes, %settingsFile%, General, IdleMinutes, %idleMinutes%
    IniRead, backupLogs, %settingsFile%, General, BackupLogs, %backupLogs%
    IniRead, saveCSV, %settingsFile%, General, SaveCSV, %saveCSV%
    IniRead, startHidden, %settingsFile%, General, StartHidden, %startHidden%
    IniRead, notify, %settingsFile%, General, EnableNotify, %notify%
    IniRead, logFolder, %settingsFile%, Output, LogFolder, %logFolder%
    IniRead, jsonFolder, %settingsFile%, Output, JsonFolder, %jsonFolder%
    IniRead, cacheFolder, %settingsFile%, Output, CacheFolder, %cacheFolder%
    IniRead, csvFile, %settingsFile%, Output, CSVFile, %csvFile%
    configSource := "INI"
}

; Rutas absolutas
logFolder := A_ScriptDir . "\\" . logFolder
jsonFolder := A_ScriptDir . "\\" . jsonFolder
cacheFolder := A_ScriptDir . "\\" . cacheFolder
logFile := logFolder . "\\Logs_System.log"
jsonFile := jsonFolder . "\\Logs_System.json"
csvPath := logFolder . "\\" . csvFile
errorLogFile := logFolder . "\\Logs_System_error.log"

; Crear carpetas
for _, folder in [logFolder, jsonFolder, cacheFolder] {
    if !FileExist(folder) {
        FileCreateDir, %folder%
        Log("[INIT] Carpeta creada: " . folder)
    } else {
        Log("[INIT] Carpeta existente: " . folder)
    }
}

; Crear archivos
if !FileExist(logFile) {
    FileAppend,, %logFile%
    Log("[INIT] Archivo creado: " . logFile)
} else {
    Log("[INIT] Archivo existente: " . logFile)
}

if !FileExist(jsonFile) {
    FileAppend,, %jsonFile%
    Log("[INIT] Archivo creado: " . jsonFile)
} else {
    Log("[INIT] Archivo existente: " . jsonFile)
}

if (saveCSV && !FileExist(csvPath)) {
    FileAppend, Date,Time,User,Host,Scan`r`n, %csvPath%
    Log("[INIT] Archivo CSV creado: " . csvPath)
} else if saveCSV {
    Log("[INIT] Archivo CSV existente: " . csvPath)
}

; Confirmar origen de configuración
Log("[INIT] Configuración cargada desde: " . configSource)

; ===== VARIABLES BASE =====
logPrefix := "[" . A_ComputerName . "][" . A_UserName . "]"
idleLimit := idleMinutes * 60000
lastActivity := A_TickCount
scanCount := 0

; ===== FUNCIONES =====
Log(msg) {
    global logFile, logPrefix, errorLogFile
    FormatTime, nowDate,, dddd dd/MM/yyyy
    FormatTime, nowTime,, HH:mm:ss
    finalLine := "[" . nowDate . " " . nowTime . "] " . logPrefix . " " . msg . "`r`n"
    FileAppend, %finalLine%, %logFile%
    ; Si es error, también lo manda a log de errores
    if InStr(msg, "ERROR")
        FileAppend, %finalLine%, %errorLogFile%
}

SaveJSON(obj) {
    global jsonFile
    jsonLine := "{" . Chr(34) . "date" . Chr(34) . ":" . Chr(34) . obj.date . Chr(34)
    jsonLine .= "," . Chr(34) . "time" . Chr(34) . ":" . Chr(34) . obj.time . Chr(34)
    jsonLine .= "," . Chr(34) . "user" . Chr(34) . ":" . Chr(34) . obj.user . Chr(34)
    jsonLine .= "," . Chr(34) . "host" . Chr(34) . ":" . Chr(34) . obj.host . Chr(34)
    if (obj.HasKey("scan"))
        jsonLine .= "," . Chr(34) . "scan" . Chr(34) . ":" . Chr(34) . obj.scan . Chr(34)
    if (obj.HasKey("status"))
        jsonLine .= "," . Chr(34) . "status" . Chr(34) . ":" . Chr(34) . obj.status . Chr(34)
    jsonLine .= "}`r`n"
    FileAppend, %jsonLine%, %jsonFile%
}

SaveCSV(obj) {
    global saveCSV, csvPath
    if !saveCSV
        return
    csvLine := obj.date "," obj.time "," obj.user "," obj.host "," obj.scan "`r`n"
    FileAppend, %csvLine%, %csvPath%
}

DetectScanner() {
    ComObjError(false)
    try {
        devices := ""
        for device in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Keyboard")
            devices .= device.Name . "; "
        Log(">>> Dispositivo de entrada detectado: " . devices)
    } catch e {
        Log("ERROR >>> Falló la detección del dispositivo: " . e.Message)
    }
}

DoBackup() {
    global backupLogs, cacheFolder, logFile
    if !backupLogs
        return
    FormatTime, nowDate,, yyyy-MM-dd
    backupFile := cacheFolder . "\\log_backup_" . nowDate . ".log"
    if !FileExist(backupFile) && FileExist(logFile)
        FileCopy, %logFile%, %backupFile%, 1
}

CheckIdle() {
    global lastActivity, idleLimit
    if (A_TickCount - lastActivity >= idleLimit) {
        obj := {date: A_NowDate(), time: A_NowTime(), user: A_UserName, host: A_ComputerName, status: "idle"}
        Log(">>> Estado: Scanner inactivo.")
        SaveJSON(obj)
        lastActivity := A_TickCount
    }
}

A_NowDate() {
    FormatTime, d,, yyyy-MM-dd
    return d
}

A_NowTime() {
    FormatTime, t,, HH:mm:ss
    return t
}

; ===== INICIO DEL SCRIPT =====
Log(">>> Script iniciado.")
DetectScanner()
DoBackup()
SetTimer, CheckIdle, 60000

Loop {
    Input, scanData, V M, {Enter}
    if (ErrorLevel = "EndKey:Enter" && scanData != "") {
        if (scanData = "TGVvbml4NDhIUg==") {
            Log(">>> Código de cierre recibido.")
            goto ExitScript
        }
        scanCount++
        Log(scanData)
        obj := {date: A_NowDate(), time: A_NowTime(), user: A_UserName, host: A_ComputerName, scan: scanData}
        SaveJSON(obj)
        SaveCSV(obj)
        lastActivity := A_TickCount
    }
}

; ESC para salir manualmente
Esc::
goto ExitScript

ExitScript:
Log(">>> Servicio detenido manualmente.")
Log(">>> Escaneos totales: " . scanCount . ".")
ExitApp
