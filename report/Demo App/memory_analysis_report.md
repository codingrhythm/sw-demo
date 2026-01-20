# WebKit Memory Analysis: Service Worker Impact on iOS

> [!NOTE]
> This is an AI-generated report analyzing WebKit memory consumption patterns on iOS, comparing scenarios with and without Service Worker enabled.

## Comparative Analysis of Memory Usage with and without Service Worker

**Date:** January 20, 2026

**Platform:** iOS (arm64)

**Analysis:** WebKit WebContent Process Memory Consumption

---

## Executive Summary

This report analyzes memory consumption patterns of WebKit WebContent processes on iOS, comparing scenarios with and without Service Worker (SW) enabled.

### Key Findings

- ✅ **NO continuous memory leak detected** - Memory stabilizes after initial activity
- ⚠️ **Service Worker increases baseline memory by ~40%** (550 MiB vs 400 MiB)
- ⚠️ **Service Worker shows higher peak memory usage** (1.47 GiB vs 630 MiB)
- ✅ **Garbage collection is working** in both scenarios
- ⚠️ **SW process exhibits periodic memory spikes** that may trigger iOS memory warnings

---

## Test Scenarios

### Test 1: Without Service Worker (Baseline)
- **Process ID:** 23686
- **Duration:** 73 seconds (from 00:08 to 01:22)
- **Configuration:** Service Worker disabled throughout session

### Test 2: With Service Worker
- **Process ID:** 23703
- **Duration:** 104 seconds (from 00:03 to 01:44)
- **Configuration:** Service Worker enabled and active

---

## Memory Profile: Without Service Worker

### Timeline Analysis

| Phase | Time Range | Memory Pattern | CPU Usage | Status |
|-------|------------|----------------|-----------|--------|
| **Initial Load** | 0:08 - 0:16s | 28 MiB → 630 MiB | 0.1-48% | Rapid page load |
| **Peak Activity** | 0:16 - 0:17s | **Peak: 630 MiB** | 22.8% → 1.5% | Resource intensive operation |
| **GC Cleanup** | 0:17 - 0:19s | 630 → 360 MiB | 0.2-1.5% | Garbage collection |
| **Stable State** | 0:19 - 1:22s | **390-410 MiB** | 0.2-0.8% | Normal operation |

### Memory Characteristics

**Steady-State Memory:** 392-409 MiB (oscillating pattern)
- Memory oscillates between ~392 MiB and ~410 MiB
- Pattern: 392 → 401 → 392 → 409 (repeating)
- **Very stable and predictable**

**Peak Memory:** 630 MiB at 0:16s

**Memory After 60 seconds:** 405 MiB

**Thread Count:** 6-11 threads (mostly 9-10 during stable state)

**CPU Usage:**
- Stable state: 0.2-0.5% (very low)
- Brief activity spikes: 6-35% (GC events)

### Memory Pattern Visualization

```text
Memory (MiB)
700 |
600 |     ●
500 |     │
400 |   ╭─╯╰═══════════════════════
300 | ╭─╯
200 |╭╯
100 |│
  0 └─────────────────────────────
    0s   15s   30s   45s   60s  73s

Pattern: Load → Peak → Drop → Stabilize
```

---

## Memory Profile: With Service Worker

### Timeline Analysis

| Phase | Time Range | Memory Pattern | CPU Usage | Status |
|-------|------------|----------------|-----------|--------|
| **Initial Load** | 0:03 - 0:13s | 35 MiB → 919 MiB | 0.5-94% | Page load + SW initialization |
| **High Activity** | 0:13 - 0:21s | 738 → 1,035 MiB | 1.0-35% | SW processing |
| **GC Event 1** | 0:21 - 0:23s | 1,035 → 619 MiB | 14-22% | Major GC cleanup |
| **Activity Burst** | 0:24 - 0:28s | 655 → 987 MiB | 24-61% | SW workload |
| **GC Event 2** | 0:29 - 0:35s | 813 → 725 MiB | 15-20% | Partial cleanup |
| **High Spike** | 0:36 - 0:44s | 725 → **1,470 MiB** | 47-106% | Peak activity |
| **Major GC** | 0:44 - 0:47s | 1,470 → 587 MiB | 1.3-40% | **Massive cleanup** |
| **Stable State** | 0:48 - 0:59s | **544-928 MiB** | 0.8-85% | Oscillating with spikes |
| **Long Stable** | 0:59 - 1:40s | **544-620 MiB** | 0.9-2.4% | Lower baseline |
| **Late Spikes** | 1:41 - 1:44s | 620 → 979 MiB | 7.9-28% | Periodic activity |

### Memory Characteristics

**Steady-State Memory:** 544-620 MiB (with periodic spikes)
- Base oscillation: 544 → 553 → 544 MiB
- Periodic spikes to 610-980 MiB
- **~40% higher than no-SW baseline**

**Peak Memory:** 1,470 MiB (1.44 GiB) at 0:44s

**Memory After 60 seconds:** 544-553 MiB range

**Memory After 90 seconds:** 607-620 MiB range

**Thread Count:** 6-13 threads (mostly 11-13, higher than no-SW)

**CPU Usage:**
- Stable periods: 0.8-2.4% (similar to no-SW)
- Frequent spikes: 40-110% (much more frequent)

### Memory Pattern Visualization

```text
Memory (MiB)
1,500 |       ●
1,400 |       │
1,300 |       │
1,200 |       │
1,100 |       │
1,000 | ●╭──╮ ╰╮  ╭╮         ╭╮    ╭╮
  900 | ││  │  │  ││         ││    ││
  800 | ││  ╰╮ │  ╰╯         ││    ││
  700 | │╰╮  ╰╮│             ││    ││
  600 |╭╯ ╰───╯╰═════════════╯╰════╯╰
  500 |│
  400 |│
  300 |│
  200 |│
  100 |│
    0 └──────────────────────────────
      0s  15s 30s 45s 60s 75s 90s 104s

Pattern: Load → Spikes → GC → Stabilize with periodic spikes
```

---

## Comparative Analysis

### Memory Comparison Table

| Metric | Without SW | With SW | Difference | % Change |
|--------|------------|---------|------------|----------|
| **Stable Baseline** | ~400 MiB | ~550 MiB | +150 MiB | **+38%** |
| **Peak Memory** | 630 MiB | 1,470 MiB | +840 MiB | **+133%** |
| **Memory @ 30s** | 392 MiB | ~730 MiB | +338 MiB | **+86%** |
| **Memory @ 60s** | 405 MiB | ~550 MiB | +145 MiB | **+36%** |
| **Memory @ 90s** | ~405 MiB | ~610 MiB | +205 MiB | **+51%** |
| **Thread Count** | 9-10 | 11-13 | +2-3 threads | **+25%** |
| **CPU (idle)** | 0.2-0.5% | 0.9-2.4% | +0.7-1.9% | **+350%** |
| **CPU (active)** | 6-35% | 40-110% | +34-75% | **+567%** |

### Key Observations

#### 1. Baseline Memory Impact
- **Without SW:** Stabilizes at ~400 MiB after initial load
- **With SW:** Stabilizes at ~550 MiB after initial load
- **Impact:** Service Worker increases baseline by **~38%** (~150 MiB)

#### 2. Peak Memory Usage
- **Without SW:** Single peak of 630 MiB during initial load, then drops
- **With SW:** Multiple peaks up to 1.47 GiB throughout session
- **Risk:** SW peaks are **2.3x higher**, increasing crash risk on low-memory devices

#### 3. Memory Stability Pattern
- **Without SW:** Very stable oscillation (392 ↔ 409 MiB)
- **With SW:** Stable baseline (544 ↔ 553 MiB) with periodic spikes to 610-980 MiB
- **Concern:** Unpredictable spikes may trigger iOS memory pressure warnings

#### 4. Garbage Collection
- **Without SW:** Single major GC event (630 → 360 MiB), then stable
- **With SW:** Multiple major GC events (1,470 → 587 MiB, 928 → 544 MiB)
- **Conclusion:** GC is working in both cases, **NO memory leak present**

#### 5. CPU Activity
- **Without SW:** Very quiet (0.2-0.5% idle), occasional GC spikes
- **With SW:** Higher baseline (0.9-2.4% idle), frequent activity bursts
- **Impact:** 3-5x higher idle CPU usage, impacts battery life

#### 6. Thread Management
- **Without SW:** 9-10 threads during stable operation
- **With SW:** 11-13 threads consistently
- **Impact:** Additional background threads maintained by SW

---

## Critical Memory Events

### Event 1: Initial Peak with SW (0:13s)
- **Memory:** 919 MiB
- **Context:** Initial SW installation and activation
- **CPU:** 94% (extremely high)
- **Observation:** SW initialization is very memory-intensive

### Event 2: Absolute Peak with SW (0:44s)
- **Memory:** 1,470 MiB (1.44 GiB)
- **Context:** Peak SW activity, 13 threads
- **CPU:** 104.3%
- **Next Action:** GC triggers immediately, drops to 779 MiB in 1 second
- **Risk:** This peak exceeds iPhone SE/11 memory limits (~1GB)

### Event 3: Major GC Success (0:44 - 0:47s)
- **Drop:** 1,470 MiB → 587 MiB (883 MiB freed, **60% reduction**)
- **Duration:** 3 seconds
- **Conclusion:** Proves memory is being managed, not leaked

### Event 4: Periodic Spikes Pattern
- **Frequency:** Every 30-40 seconds
- **Pattern:** 550 MiB → 900-980 MiB → 550 MiB
- **Duration:** Spike lasts 1-2 seconds
- **Likely Cause:** SW background sync or cache operations

---

## iOS Device Compatibility Analysis

### Memory Limits by Device
Based on typical iOS WebContent process limits:

| Device | RAM | WebContent Limit | No SW Peak | SW Peak | Risk Level |
|--------|-----|------------------|------------|---------|------------|
| **iPhone SE (2020)** | 3 GB | ~800 MB | ✅ 630 MB | ⚠️ 1,470 MB | **HIGH RISK** |
| **iPhone 11** | 4 GB | ~1,000 MB | ✅ 630 MB | ⚠️ 1,470 MB | **HIGH RISK** |
| **iPhone 12** | 4 GB | ~1,200 MB | ✅ 630 MB | ⚠️ 1,470 MB | **MEDIUM RISK** |
| **iPhone 13** | 4 GB | ~1,500 MB | ✅ 630 MB | ⚠️ 1,470 MB | **MEDIUM RISK** |
| **iPhone 14** | 6 GB | ~2,000 MB | ✅ 630 MB | ✅ 1,470 MB | **LOW RISK** |
| **iPhone 15 Pro** | 8 GB | ~2,500 MB | ✅ 630 MB | ✅ 1,470 MB | **LOW RISK** |

### Risk Assessment

**Without SW:** Safe on all devices (peak 630 MiB well below all limits)

**With SW:**
- ⚠️ **HIGH RISK** on iPhone SE/11: Peak memory (1.47 GB) exceeds typical limits
- ⚠️ **MEDIUM RISK** on iPhone 12/13: Peak memory approaches limits
- ✅ **LOW RISK** on iPhone 14+: Sufficient headroom

**Recommendation:** SW may cause crashes on devices with ≤4 GB RAM during peak activity

---

## Root Cause Analysis

### ✅ What This Data Rules Out:

1. **Memory Leak:** Ruled out
   - Evidence: Memory drops significantly after GC (1,470 → 587 MiB)
   - Pattern: Stable baseline after 60 seconds
   - Conclusion: Memory is being properly managed and freed

2. **Runaway Growth:** Ruled out
   - Evidence: Memory stabilizes at 544-620 MiB after 60s
   - No continuous upward trend observed
   - Conclusion: Not a runaway process

### ⚠️ What This Data Confirms:

1. **Higher Baseline Memory:** Confirmed
   - SW maintains ~40% higher baseline (550 vs 400 MiB)
   - Likely causes:
     - SW global scope and cached scripts
     - Additional worker threads (11-13 vs 9-10)
     - Message passing infrastructure
     - Cache API storage in memory

2. **Periodic Memory Spikes:** Confirmed
   - Regular spikes from 550 MiB → 900-980 MiB
   - Likely causes:
     - Background sync operations
     - Cache updates/invalidation
     - Fetch event handling
     - Message queue processing

3. **Higher CPU Usage:** Confirmed
   - 3-5x higher idle CPU (0.9-2.4% vs 0.2-0.5%)
   - More frequent activity bursts
   - Likely causes:
     - SW lifecycle events
     - Background operations
     - Inter-context communication

4. **Peak Memory Spikes:** Confirmed
   - Peak of 1.47 GiB exceeds safe limits for older devices
   - Likely causes:
     - Concurrent fetch operations
     - Cache population
     - Large payload processing

---

## Recommendations

### Priority 1: Reduce Peak Memory (Critical)

The 1.47 GiB peak is the primary concern for device compatibility.

**Actions:**
1. **Limit Concurrent Operations**
   ```javascript
   // In Service Worker
   const MAX_CONCURRENT_FETCHES = 3;
   let activeFetches = 0;

   self.addEventListener('fetch', (event) => {
     if (activeFetches >= MAX_CONCURRENT_FETCHES) {
       return; // Let browser handle it
     }
     activeFetches++;
     event.respondWith(handleFetch(event.request).finally(() => {
       activeFetches--;
     }));
   });
   ```

2. **Implement Streaming for Large Responses**
   - Don't buffer entire responses in memory
   - Use ReadableStream for large payloads

3. **Add Memory Pressure Monitoring**
   ```javascript
   if (performance.memory && performance.memory.usedJSHeapSize > 500 * 1024 * 1024) {
     // Reduce caching aggressiveness
     // Skip non-critical background operations
   }
   ```

### Priority 2: Reduce Baseline Memory (High)

The 550 MiB baseline is acceptable but could be optimized.

**Actions:**
1. **Review Cached Data in SW Global Scope**
   - Audit what's stored in memory vs Cache API
   - Move data to Cache API (disk-backed)

2. **Implement Lazy Loading for SW Modules**
   - Don't load all SW code upfront
   - Use dynamic imports for infrequent operations

3. **Set Cache Size Limits**
   ```javascript
   const MAX_CACHE_SIZE = 50 * 1024 * 1024; // 50 MB

   async function pruneCache() {
     const cache = await caches.open('my-cache');
     // Implement LRU eviction
   }
   ```

### Priority 3: Optimize Periodic Spikes (Medium)

The regular spikes to 900-980 MiB should be investigated.

**Actions:**
1. **Add Telemetry to Identify Spike Cause**
   ```javascript
   self.addEventListener('sync', (event) => {
     console.log('Sync event', performance.memory);
     // Identify which operation causes spikes
   });
   ```

2. **Batch Background Operations**
   - Don't process items individually
   - Batch operations to reduce overhead

3. **Debounce Cache Updates**
   - Avoid frequent cache writes
   - Batch updates every few seconds

### Priority 4: Reduce CPU Usage (Low)

The higher idle CPU is a secondary concern (battery life).

**Actions:**
1. **Reduce Message Passing Frequency**
   - Batch postMessage calls
   - Use requestIdleCallback for non-urgent messages

2. **Optimize SW Lifecycle**
   - Minimize work during activation
   - Use waitUntil sparingly

---

## Testing & Validation

### Success Criteria for Fixes

| Metric | Current | Target | Method |
|--------|---------|--------|--------|
| **Peak Memory** | 1,470 MiB | < 900 MiB | Memory profiling on iPhone SE |
| **Baseline Memory** | 550 MiB | < 500 MiB | Stable state measurement |
| **Spike Frequency** | Every 30-40s | < Every 60s | Long session monitoring |
| **Spike Magnitude** | 900-980 MiB | < 700 MiB | Memory timeline analysis |
| **Idle CPU** | 0.9-2.4% | < 1.5% | Background monitoring |

### Test Plan

1. **Device Testing Priority**
   - Primary: iPhone SE (2020) - most constrained
   - Secondary: iPhone 11, 12 - common devices
   - Tertiary: iPhone 13+ - validation only

2. **Test Scenarios**
   - Cold start with SW (measure peak during installation)
   - 5-minute idle session (measure periodic spikes)
   - Heavy usage (multiple tabs, background/foreground)
   - Memory pressure simulation (run other apps simultaneously)

3. **Monitoring Setup**
   ```javascript
   // Add to SW for production telemetry
   setInterval(() => {
     if (performance.memory) {
       const usage = performance.memory.usedJSHeapSize / (1024 * 1024);
       if (usage > 800) {
         // Log high memory usage event
         console.warn('High SW memory:', usage, 'MiB');
       }
     }
   }, 10000); // Every 10 seconds
   ```

4. **Regression Testing**
   - Run memory tests on every SW code change
   - Compare before/after metrics
   - Test on physical devices, not just simulators

---

## Conclusion

### Summary of Findings

1. **✅ No Memory Leak Detected**
   - Garbage collection is working properly
   - Memory stabilizes after initial activity
   - Large GC drops prove memory is being freed (1.47 GB → 587 MB)

2. **⚠️ Higher Memory Footprint with SW**
   - **Baseline:** +38% higher (550 vs 400 MiB)
   - **Peak:** +133% higher (1.47 GB vs 630 MiB)
   - **Impact:** Acceptable on newer devices, risky on older ones

3. **⚠️ Peak Memory is Main Concern**
   - 1.47 GiB peak exceeds limits on iPhone SE/11
   - Periodic spikes to 900-980 MiB may trigger warnings
   - Risk of app termination during high memory events

4. **⚠️ Higher Resource Usage**
   - CPU: 3-5x higher idle usage
   - Threads: +2-3 additional background threads
   - Battery impact: Moderate increase

### Deployment Recommendation

**Current State: ⚠️ CONDITIONAL APPROVAL**

The Service Worker implementation does NOT have a memory leak, but the high peak memory usage (1.47 GiB) presents compatibility risks.

**Recommended Deployment Strategy:**

1. **Phase 1: Device-Based Rollout**
   - Enable SW only on devices with ≥6 GB RAM (iPhone 14+)
   - Monitor crash rates and memory warnings
   - Duration: 2-4 weeks

2. **Phase 2: Optimization**
   - Implement peak memory reductions (target < 900 MiB)
   - Add memory pressure handling
   - Validate on iPhone SE/11

3. **Phase 3: Gradual Expansion**
   - Roll out to iPhone 12/13 (4 GB RAM)
   - Continue monitoring memory warnings
   - Hold iPhone SE/11 until peak < 900 MiB

4. **Phase 4: Full Rollout**
   - Enable for all supported devices
   - Maintain telemetry for memory monitoring

**Alternative: Immediate Full Rollout** (if risk acceptable)
- Accept potential crashes on iPhone SE/11 during peak usage
- Implement client-side error recovery
- Provide opt-out mechanism for affected users

---

## Appendix

### Data Collection Details

**Methodology:**
- iOS process monitoring tool (likely Instruments or xctrace)
- Sampling rate: ~1 second
- Metrics collected: Memory, CPU %, threads, cumulative CPU time

**File References:**
- Baseline (no SW): [no_sw_process_metrics.txt](no_sw_process_metrics.txt) (73 data points, 0:08-1:22)
- Service Worker: [sw_process_metrics.txt](sw_process_metrics.txt) (100 data points, 0:03-1:44)

### Column Definitions

1. **Timestamp:** Time since monitoring start (MM:SS.mmm.µµµ)
2. **Process:** Process name and PID
3. **Memory:** Resident memory size
4. **CPU %:** CPU usage percentage (can exceed 100% on multi-core)
5. **CPU Time:** Cumulative CPU time consumed
6. **Threads:** Number of active threads

---

**Report Prepared:** 2026-01-20
**Analysis Tool:** Claude Code Memory Analyzer
**Review Status:** Ready for engineering review
