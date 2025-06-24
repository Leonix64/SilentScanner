# Scanner Service (Modo Discreto)

Este proyecto es un servicio de escaneo automático con registro en múltiples formatos, detección de inactividad y estructura modular basada en AutoHotkey. Está diseñado para ejecutarse en segundo plano de forma silenciosa y sin intervención del usuario.

---

## 📁 Estructura del Proyecto

Scanner/
├── drv/
│ ├── .cache/ ← Backups automáticos diarios del log
│ ├── logs/ ← Registros en formato .log y .csv
│ ├── json/ ← Registros en formato .json
│ └── settings.ini ← Configuración del sistema
├── MpRunStub.ahk ← Código fuente principal
├── MpRunStub.exe ← Ejecutable compilado
├── Launcher.vbs ← Lanza el ejecutable de forma oculta
└── README.md ← Este archivo

---

## ⚙️ Configuración: `settings.ini`

```ini
[General]
IdleMinutes=5          ; Minutos sin actividad para marcar como "inactivo"
BackupLogs=1           ; 1 = activa backup diario del log
SaveCSV=1              ; 1 = guarda registros también en CSV
StartHidden=1          ; 1 = ejecuta en modo oculto
EnableNotify=0         ; 1 = activa notificaciones

[Output]
LogFolder=drv\logs
JsonFolder=drv\json
CacheFolder=drv\.cache
CSVFile=Scans.csv
