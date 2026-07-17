# Chapter 02 - DIY Cooling and Battery Protection

## Goal

This chapter defines the physical cooling and battery-protection design for a laptop-based 24/7 home lab.

The reference machine is a ThinkPad T14 Gen 2. The same design can be adapted to other business laptops, but the airflow direction and vent locations must be checked before building the enclosure.

## Design Objective

The objective is not to make the laptop run at maximum performance. The objective is to keep it stable, clean, and thermally predictable during continuous operation.

| Objective | Target |
| --- | --- |
| CPU idle temperature | 35-45 C |
| CPU normal VM workload | 55-70 C |
| CPU sustained temperature | Avoid 85 C and above |
| SSD temperature | Below 60 C |
| Battery charge level | Keep around 45-50% |
| Dust maintenance | Clean external filter monthly |

These numbers are practical targets, not guarantees. Ambient temperature, dust, fan quality, workload, and thermal paste condition all affect the result.

## Why Cooling Matters

A laptop used as a server runs in a different pattern from normal office use.

Normal laptop usage:

- Short work sessions.
- Frequent sleep or shutdown.
- Periods of low heat.
- Battery charge and discharge cycles.

Home lab usage:

- Runs 24/7.
- Keeps VM and container workloads active.
- Stays plugged in.
- May sit in one place for months.

Without thermal planning, the machine can collect dust faster, run its internal fan harder, and keep the battery at an unhealthy charge level for long periods.

## ThinkPad Airflow Assumption

The ThinkPad T14 Gen 2 generally follows this airflow pattern:

```text
Cool air intake: bottom cover
Hot air exhaust: side exhaust vent
```

Before building the enclosure, verify your exact unit:

1. Shut down the laptop.
2. Inspect the bottom cover for intake slots.
3. Inspect the side edges for the exhaust vent.
4. Confirm the exhaust side should face upward when the laptop is stored vertically.

The cooling design must feed clean air toward the laptop intake area. Do not block the exhaust vent.

## Recommended Physical Orientation

Use the laptop closed and vertical.

| Position | Recommendation |
| --- | --- |
| Lid | Closed |
| Orientation | Vertical |
| Exhaust vent | Facing upward |
| Bottom intake | Facing the filtered air chamber |
| Screen | Not used during normal operation |

This orientation saves desk space and helps hot air rise away from the machine instead of recirculating near the intake.

## Cooling Design

The recommended cooling concept is a vertical filtered plenum chamber.

Diagram source: [`../diagrams/diy-cooling.mmd`](../diagrams/diy-cooling.mmd)

![DIY cooling airflow](assets/images/diy-cooling.png)

```text
Room air
  |
  v
Magnetic dust filter
  |
  v
120 mm static pressure fan
  |
  v
Sealed plenum chamber
  |
  v
Laptop bottom intake
  |
  v
Laptop internal fan and heatsink
  |
  v
Side exhaust vent facing upward
```

The external fan does not replace the internal laptop fan. It supplies filtered air into a small chamber so the laptop intake receives cleaner and more consistent airflow.

## Why Use a Plenum Chamber

A normal cooling pad blows air into open space. Much of the air escapes around the laptop before reaching the intake.

A plenum chamber improves this by:

- Reducing air leakage.
- Increasing positive pressure near the laptop intake.
- Forcing air through the intended path.
- Allowing dust filtering before air reaches the laptop.

This is a simple version of the same idea used in many server and workstation airflow designs: guide the air instead of merely adding more fans.

## Material Selection

| Material | Recommendation | Reason |
| --- | --- | --- |
| Main enclosure | 5 mm PVC/Formex board | Light, rigid, easy to cut |
| Seal | 3-5 mm EPDM foam | Reduces air leaks and vibration |
| Fan | 120 mm static pressure fan | Better against filter and chamber resistance |
| Filter | 120 mm magnetic dust filter | Easy to remove and clean |
| Power | 12 V DC adapter, 1-2 A | Keeps fan power independent from the laptop |

Avoid cardboard for long-term use. It absorbs moisture, flexes easily, and is not a good permanent material near electronics.

## Suggested Dimensions

The enclosure should be sized after measuring your laptop.

For a ThinkPad T14 Gen 2 reference build:

| Dimension | Suggested Starting Point |
| --- | --- |
| Internal height | Laptop height plus 10-20 mm clearance |
| Internal width | Laptop thickness plus gasket compression space |
| Chamber depth | 60-90 mm |
| Fan opening | 120 mm fan cutout |
| Filter size | Match fan size |

Do not make the chamber too tight. The laptop should be held securely, but the enclosure should not apply bending pressure to the chassis.

## Fan Selection

Prefer a static pressure fan over a pure airflow fan.

| Fan Type | Best For | Recommendation |
| --- | --- | --- |
| Airflow fan | Open-air cases | Not ideal |
| Static pressure fan | Filters, radiators, restrictive paths | Recommended |

Practical examples:

- Arctic P12
- Noctua NF-F12
- be quiet! Silent Wings 120 mm
- Cooler Master Mobius 120 mm

Use a quiet fan curve if your fan controller supports it. The goal is stable continuous airflow, not maximum noise.

## Dust Filter Placement

Install the dust filter before the fan intake:

```text
Room air -> Dust filter -> Fan -> Chamber -> Laptop
```

This keeps the fan blades and laptop intake cleaner. A magnetic filter is convenient because it can be removed and cleaned without opening the enclosure.

## Gasket and Air Leakage

Air leakage reduces chamber effectiveness. Use EPDM foam or silicone foam on the contact points.

Seal these areas:

- Around the laptop intake-facing side.
- Around the chamber edges.
- Around the fan mount if there are gaps.
- Around removable panels if used.

Do not seal the laptop exhaust. The exhaust must remain fully open.

## Build Procedure

### Step 1 - Confirm Airflow Direction

Identify the laptop intake and exhaust before cutting material.

Expected result:

- Intake side faces the plenum chamber.
- Exhaust vent points upward.

### Step 2 - Cut the Enclosure Panels

Cut the enclosure panels from PVC/Formex board.

Recommended panel set:

- Back panel.
- Left side panel.
- Right side panel.
- Bottom support panel.
- Fan panel.
- Optional removable service panel.

Keep the design simple for v1.0. A removable filter is more important than a complex shape.

### Step 3 - Cut the Fan Opening

Cut a 120 mm fan opening on the intake side.

Mounting order:

```text
Outside -> Dust filter -> Fan -> Chamber
```

Make sure the fan blows into the chamber, not away from it.

### Step 4 - Install Gaskets

Apply foam gasket where the laptop contacts the enclosure.

The gasket should:

- Hold the laptop gently.
- Reduce vibration.
- Close major air gaps.
- Avoid pressing hard on the screen lid.

### Step 5 - Test Fit the Laptop

Insert the closed laptop vertically.

Check:

- Exhaust vent is not blocked.
- USB-C power cable has enough clearance.
- Power button access is still possible or Wake-on-LAN/remote startup plan is understood.
- The laptop can be removed without forcing it.

### Step 6 - Power and Test the Fan

Connect the fan to the 12 V adapter.

Verify:

- Air enters through the filter.
- Air pressure can be felt near the laptop intake.
- There is no major air leak around the fan mount.
- Noise level is acceptable for 24/7 use.

### Step 7 - Thermal Baseline Test

Measure temperatures before and after using the chamber.

Record:

- Ambient room temperature.
- CPU package temperature at idle.
- CPU package temperature under normal VM workload.
- SSD temperature.
- Fan noise level by observation.

Use HWiNFO64 or another trusted hardware monitor.

## Battery Charge Threshold

A laptop that is always plugged in should not keep its battery at 100%.

Recommended setting:

| Setting | Value |
| --- | --- |
| Start charging | 45% |
| Stop charging | 50% |

On Lenovo systems, configure this in Lenovo Commercial Vantage:

```text
Lenovo Commercial Vantage
  -> Device
  -> Power
  -> Battery
  -> Battery Charge Threshold
```

If your version shows Conservation Mode instead of exact thresholds, enable Conservation Mode. Exact UI labels can vary by Lenovo software version and firmware support.

## Power Settings Related to Hardware Safety

These settings are covered in detail in Chapter 03, but they affect the physical deployment:

| Setting | Target |
| --- | --- |
| Lid close on AC power | Do nothing |
| Sleep on AC power | Never |
| Hibernate | Disabled |
| CPU boost policy | Disabled or limited |
| Maximum processor state | 99% if using the simple anti-boost method |

Do not close the laptop and place it into the vertical stand until the lid-close behavior is configured.

## Maintenance Routine

| Interval | Task |
| --- | --- |
| Weekly | Check CPU, SSD, and RAM readings |
| Monthly | Remove and clean dust filter |
| Monthly | Inspect fan noise and vibration |
| Quarterly | Inspect laptop vents for dust accumulation |
| Every 6-12 months | Consider internal dust cleaning if temperatures rise |
| Every 12-24 months | Consider thermal paste replacement if needed |

If temperatures slowly rise over time while workload stays the same, dust buildup is the first thing to check.

## Safety Notes

- Do not block the laptop exhaust vent.
- Do not use flammable or weak materials for a permanent enclosure.
- Do not apply pressure to the screen lid.
- Do not run the fan from an underpowered USB port unless the fan is designed for USB.
- Do not place the setup near curtains, bedding, or paper stacks.
- Do not ignore battery swelling. Stop using the battery if swelling is visible.

## Common Mistakes

| Mistake | Impact |
| --- | --- |
| Using a high-CFM airflow fan with weak pressure | Poor performance through filter and chamber |
| Placing the filter after the fan | Fan blades collect dust |
| Sealing the exhaust side | Causes heat buildup |
| Keeping battery at 100% | Accelerates battery aging |
| Making the enclosure too tight | Can stress the laptop chassis |
| Measuring only idle temperature | Misses thermal behavior under real workload |

## Verification Checklist

- [ ] Laptop is closed and vertical.
- [ ] Exhaust vent faces upward and is unobstructed.
- [ ] Bottom intake faces the plenum chamber.
- [ ] Dust filter is installed before the fan.
- [ ] Fan blows into the chamber.
- [ ] Gasket reduces major air leaks.
- [ ] Battery charge threshold is configured.
- [ ] CPU temperature is acceptable under normal VM workload.
- [ ] SSD temperature stays below 60 C.
- [ ] Filter can be removed without disassembling the full setup.

## Exit Criteria

Before moving to Windows host optimization, confirm:

- The laptop can physically run in the planned closed vertical position.
- Cooling airflow is stable and not blocked.
- Battery charge protection is configured or the risk is explicitly accepted.
- You have a baseline temperature reading for future comparison.
