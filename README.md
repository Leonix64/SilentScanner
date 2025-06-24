# Servicio modular de escaneo en segundo plano

**SilentScanner** es un servicio de escaneo pasivo basado en AutoHotkey que opera en modo sigiloso. Detecta entradas de dispositivos de escaneo como teclados o lectores de código, registra la actividad en múltiples formatos (.log, .json, .csv) y responde automáticamente a eventos como inactividad o códigos especiales.

Ideal para entornos donde se requiere:
- **auditoría encubierta**
- **registro constante**
- **comportamiento sin intervención visible del usuario**

---

## 🧩 Características

- 🔎 Detección silenciosa de escaneos (teclado/lector de código)
- 🕵️‍♂️ Operación en modo sigilo (sin ventana, sin iconos)
- 🧠 Configuración externa por archivo `settings.ini`
- 📝 Registro estructurado: `.log`, `.json`, y `.csv`
- 💤 Detección de inactividad configurable
- 🔁 Backup automático de logs diarios
- 🛑 Salida por tecla `Esc` o código
- 🛠️ Totalmente modular y personalizable

---

## 📁 Estructura del Proyecto

```
Scanner/
├── drv/
│   ├── .cache/         ← Backups automáticos diarios
│   ├── logs/           ← Registros en .log y .csv
│   ├── json/           ← Registros en .json
│   └── settings.ini    ← Configuración dinámica
├── MpRunStub.ahk       ← Código fuente principal (AutoHotkey)
├── MpRunStub.exe       ← Ejecutable compilado (modo fantasma)
├── Launcher.vbs        ← Script para ejecutar oculto
└── README.md           ← Este archivo
```

---

## ⚙️ Configuración — `settings.ini`

Archivo editable por el usuario para modificar el comportamiento del servicio sin tocar el código.

```ini
[General]
IdleMinutes=5          ; Minutos para marcar como inactivo
BackupLogs=1           ; 1 = habilitar respaldo diario de logs
SaveCSV=1              ; 1 = guardar también como CSV
StartHidden=1          ; 1 = modo oculto al arrancar
EnableNotify=0         ; 1 = notificaciones activadas

[Output]
LogFolder=drv\logs
JsonFolder=drv\json
CacheFolder=drv\.cache
CSVFile=Scans.csv
```

---

## 🧠 Cierre del servicio

El servicio se puede cerrar de dos formas:

- Presionando `Esc`
- Escaneando este código secreto base64(configurable):
  ```
  TGVvbml4NDhIUg==
  ```

Ambos métodos registran el cierre en los logs.

---

## 🛡️ Requisitos

- [AutoHotkey v1.1+](https://www.autohotkey.com/)
- Windows 7/10/11
- Permisos de escritura en la ruta del ejecutable

---

## 🧪 Compilación

Para crear el `.exe`:

1. Abre `Ahk2Exe` (viene con AutoHotkey)
2. Selecciona `MpRunStub.ahk` como script fuente
3. Establece icono personalizado si quieres
4. Compílalo como `Windows GUI` (no consola)

Opcionalmente, usa `Launcher.vbs` para ejecutarlo en modo invisible desde acceso directo o arranque.

---
