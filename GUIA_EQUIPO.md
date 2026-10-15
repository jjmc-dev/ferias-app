# GUÍA DEL EQUIPO — Cómo trabajar con CONTEXTO.md y la IA

Esta guía es para los 6 integrantes. El objetivo es que todos avancemos en la misma dirección, con la IA que
cada uno prefiera, y que cada uno pueda **explicar su parte sin ayuda** cuando el licenciado pregunte.

## 1. Preparar la PC (Windows 11)

1. **Git** y una cuenta de GitHub (o la plataforma que elija el delegado).
2. **Docker Desktop** con WSL2 (si pide activar la virtualización, se hace en la BIOS). Comprobar con `docker --version`.
3. **Python 3.12** (marcar "Add to PATH" al instalar). Comprobar con `python --version`.
4. **VS Code** (u otro editor).
5. Clonar el repositorio que comparte el delegado y crear tu rama: `git checkout -b modulo-N-nombre`.

## 2. Qué hacer paso a paso

1. **Lee `CONTEXTO.md` completo** (10 minutos). Sin entender el contexto, la IA te dará respuestas que no encajan.
2. **Abre un chat nuevo** con tu IA (ChatGPT, Gemini, DeepSeek, Claude, la que uses).
3. **Pega el contenido de `CONTEXTO.md`** y, en el mismo mensaje o en el siguiente, adjunta lo que tu módulo
   necesita (tabla de abajo) y di qué módulo te tocó (usa la plantilla de la sección 3).
4. **Trabaja en pasos pequeños.** Pídele un archivo a la vez, pruébalo, y recién entonces sigue.
5. **Pide que te explique** cada archivo y cada comando ("explícame línea por línea qué hace esto").
6. **Si algo falla**, pega el **error completo** y lo que ya intentaste. No escribas solo "no funciona".
7. **Haz commits pequeños** con tu propia cuenta (`git add`, `git commit -m "mensaje claro"`, `git push`).
8. **Escribe tu sección del tutorial** en `docs/tutorial-modulo-N.md`: qué hace tu módulo, cómo se instala o ejecuta,
   qué problemas tuviste y cómo los resolviste.
9. **Avisa al delegado** cuando termines para integrar y que otro compañero revise tu trabajo.

## 3. Plantilla para el primer mensaje a la IA

> [pegar aquí todo el contenido de CONTEXTO.md]
>
> Soy integrante del Grupo 5 y mi módulo es el **Módulo N: (nombre del módulo)**.
> Mi PC es Windows 11 con Docker Desktop y Python 3.12. Mi nivel: (principiante / intermedio) en Python.
> Quiero avanzar **paso a paso**. Antes de darme código, dime el plan de tu módulo en 5 pasos y espera mi
> confirmación. Cada vez que me des código, explícame qué hace, porque tengo que poder explicarlo en clase sin
> ayuda. Respeta el contrato del backend de la sección 7 de CONTEXTO.md.

## 4. Qué adjuntar a la IA según tu módulo

| Módulo | Adjuntar además de CONTEXTO.md |
|---|---|
| 1 — Infraestructura Docker | Ningún archivo extra (con CONTEXTO.md alcanza) |
| 2 — Base de datos | `scrip_create_insert_rev10.txt` (Oracle) y el modelo relacional. Usa la sección 6 de CONTEXTO.md (pistas y totales esperados) |
| 3 — Backend núcleo | Ningún archivo extra; usa la sección 7 del contexto |
| 4 — Multi-motor | El `base.py` del Módulo 3 cuando esté listo |
| 5 — Frontend | La lista de endpoints (sección 7.3) y, cuando exista, el backend en marcha |
| 6 — Rutinas SQL | `scrip_create_insert_rev10.txt`, el modelo ER y el relacional. Compara tus resultados con los valores esperados de la sección 8 de CONTEXTO.md |

## 5. Reglas para usar bien la IA

- La IA **ayuda**, no reemplaza: tú debes poder responder "¿qué lenguaje usaste, cómo se conecta, qué hace este
  archivo?" sin ella.
- Dale siempre **contexto completo** (por eso existe `CONTEXTO.md`) y menciona versiones y sistema operativo.
- **Prueba** todo lo que te entregue antes de seguir; las IAs a veces inventan nombres o comandos.
- **No pegues contraseñas reales ni datos personales** en el chat.
- **Comprueba con números.** CONTEXTO.md trae totales y valores esperados con el rev10 (filas por tabla, resultados de
  las funciones). Si tu resultado no coincide, hay un error en tu código o en tu script, aunque "no dé error".
- Si la IA propone cambiar algo del contrato (nombres de endpoints, de tablas, estructura de carpetas), **consulta
  primero al delegado**, porque afecta a otros módulos.

## 6. Ensayo antes de la presentación (20 minutos entre todos)

Cada uno responde en voz alta, sin mirar la IA:

1. ¿Qué lenguaje usamos y por qué?
2. ¿Qué hace tu módulo y cómo se conecta con los demás?
3. ¿Cómo se levanta el proyecto desde cero? (comandos)
4. ¿Cómo sabe el backend a qué motor conectarse?
5. ¿Qué pasaría si mañana nos dan una base de PostgreSQL?
6. ¿Cómo evitamos la inyección SQL?
7. ¿Qué diferencia hay entre una función y un procedimiento? ¿Y cómo funciona un cursor y un trigger?

## 7. Calendario

| Día | Meta del equipo |
|---|---|
| Jueves | Repositorio, SQL Server en Docker con el script cargado, backend y frontend mínimos |
| Viernes | Rutinas SQL listas, endpoints de rutinas, primeros adaptadores |
| Sábado | Todo conectado de punta a punta, adaptadores probados |
| Domingo | Prueba en una PC limpia de otro integrante, corrección de fallas, ensayo |
| Lunes y martes | Tutorial final (cada uno aporta su sección) y entrega del martes 20 |
