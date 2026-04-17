# SASP Job (FiveM) — Custom Framework + Optional QBCore Bridge

A feature-rich **San Andreas State Police** job resource designed for servers that want:

- A **custom standalone framework mode** (no mandatory QBCore dependency for core job logic).
- A **QBCore bridge mode** for money/inventory/job interoperability.
- Strong out-of-the-box gameplay: duty flow, dispatch, panic, armory, loadouts, officer payroll, incident logs, and arrest tracking.

---

## Highlights

### Framework Architecture
- **Auto-detect mode** (`Config.Framework.mode = 'auto'`): uses QBCore when present, otherwise runs standalone custom mode.
- **Custom framework player state**:
  - lightweight job state
  - inventory table
  - bank/cash accounts
  - metadata counters for calls and arrests
- **QBCore bridge mode**:
  - Reads job data from `PlayerData.job`
  - Toggles duty using `SetJobDuty`
  - Uses QBCore money/inventory when enabled

### Core SASP Systems
- Duty toggle command + in-world duty station markers (`/saspduty`, key prompt at stations).
- Patrol call management:
  - create calls (`/sasp_call [10-code]`)
  - request backup (`/sasp_backup [code]`)
  - accept call (`/sasp_accept [CALL-ID]`)
  - resolve call (`/sasp_resolve [CALL-ID] [notes]`)
- Panic button (`/sasp_panic`) broadcasting emergency radius blip.
- Armory system:
  - rank-gated equipment catalog
  - text-driven armory listing + withdrawal command flow
- Rank-based standard issue loadouts (`/sasp_loadout`).
- Duty payroll loop with bonuses based on:
  - calls handled
  - arrests made

### Data Persistence
- Incident reports stored in MySQL table (`sasp_incidents`) with full JSON payload.
- Arrest records stored in MySQL table (`sasp_arrests`).

### Traffic Enforcement Tools
- Front radar mode (`/sasp_radar`) showing:
  - target plate
  - vehicle model
  - speed in MPH

---

## Resource Structure

```txt
sasp_job/
├─ fxmanifest.lua
├─ config.lua
├─ shared/
│  ├─ framework.lua
│  └─ utils.lua
├─ server/
│  ├─ main.lua
│  ├─ duty.lua
│  ├─ calls.lua
│  └─ armory.lua
├─ client/
│  ├─ main.lua
│  ├─ duty.lua
│  ├─ traffic.lua
│  └─ backup.lua
└─ sql/
   └─ sasp_job.sql
```

---

## Requirements

- **oxmysql**
- *(optional)* **qb-core** when using `qbcore` or `auto` mode and QBCore is running.

---

## Installation

1. Copy this resource to your server resources folder (e.g., `resources/[jobs]/sasp_job`).
2. Run SQL from `sql/sasp_job.sql`.
3. Ensure dependencies are started first:
   - `ensure oxmysql`
   - `ensure qb-core` *(optional, if using QBCore bridge)*
4. Add this resource:
   - `ensure sasp_job`
5. Configure `config.lua`:
   - Set framework mode
   - Set job name / ranks / pay / stations / loadouts

---

## Configuration Notes

### Framework Mode

```lua
Config.Framework.mode = 'auto' -- auto | custom | qbcore
```

- `auto`: uses QBCore if running, else custom mode.
- `custom`: forces standalone mode.
- `qbcore`: forces QBCore mode.

### Job Matching

Players must have `job.name == Config.Job.name` (default: `sasp`) to access SASP features.

### QBCore Job Bootstrap (Fix for `/setjob`)

If `/setjob 1 sasp 0` fails because `sasp` is not in your QBCore jobs table, this resource can auto-register it at runtime:

- `Config.QBCoreJobBootstrap.enabled = true`
- Defines default job grades/labels/pay in `config.lua`
- Registers `Config.Job.name` into `QBCore.Shared.Jobs` when the resource starts

You can disable this if you already define the job manually in your core.

### Grade-Based Features

- Armory equipment and standard loadouts are mapped by job grade.
- Payroll base salary is grade-based and bonuses are performance-based.

---

## Commands

- `/saspduty` — Toggle on/off duty.
- `/sasp_loadout` — Receive rank-based standard loadout.
- `/sasp_armory` — Print your rank-allowed armory item list.
- `/sasp_armory_take [itemname]` — Withdraw one armory item by spawn name.
- `/sasp_call [code]` — Create a dispatch call.
- `/sasp_backup [code]` — Request backup.
- `/sasp_accept [CALL-ID]` — Accept an open call.
- `/sasp_resolve [CALL-ID] [notes]` — Resolve active/open call.
- `/sasp_panic` — Trigger panic button alert.
- `/sasp_radar` — Toggle speed radar overlay.

---

## Suggested Extensions (Easy to Add)

- Prison/jail handoff integration.
- Full MDT UI (NUI) with search/citation/warrant modules.
- BOLO system with automatic ALPR cross-check.
- Evidence chain logs (casings, blood, fingerprints).
- License status API integration (suspended/revoked).
- Court/case lifecycle state machine.

---

## SQL

Use `sql/sasp_job.sql` to create core tables for incidents and arrests.

---

## License

Use/edit freely for your community. Attribution appreciated.
