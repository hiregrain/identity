// checks/plan-graph.mjs proves the dependency graph is valid and computes
// the workable frontier, never hand-maintained (plans/ORDER.md,
// foundation/06). Two halves:
//
//   1. Validation. Every depends_on referent resolves. A layer names
//      existing layers; a task names `<layer>/<NN>` where the layer
//      exists. A task file missing under a `draft` layer is UNAUTHORED,
//      not dangling: ORDER.md authors task files only when a layer's
//      grilling closes, so forward references to unauthored tasks are
//      the normal state and simply block. The same missing file under a
//      non-draft layer IS dangling, because that layer's decomposition is
//      final, so the referent should exist. No dependency cycle may
//      exist among layers or among tasks.
//
//   2. The frontier. A task is workable when its own status is `ready`,
//      every task in its depends_on is `done`, its layer is `ready`, and
//      every layer in its layer's depends_on is `done`, the layer-level
//      gate on the layer's tasks. ORDER.md's "dependencies are per task,
//      not per layer" sentence reads as if a task-level dep into a layer
//      could override that gate; no decision rules it, so the strict
//      reading stands here and the looser one is a raised question, not
//      a quiet default.
//
// `blocked` is computed here and never stored (ORDER.md's status
// vocabulary has no such state). checks/run.mjs imports computeFrontier
// to print the queue after every check passes.
//
// Usage: node checks/plan-graph.mjs [plans-root]
// Dependency-free Node, no database.

import { pathToFileURL } from "node:url";
import { readPlanFiles } from "./lib/plan-files.mjs";

export function analyze(root) {
  const failures = [];
  const layers = new Map(); // id -> { status, dependsOn }
  const tasks = new Map(); // id -> { status, dependsOn, layer }

  for (const file of readPlanFiles(root)) {
    const { path, dir, fields } = file;
    const type = fields.get("type")?.raw;
    const id = fields.get("id")?.raw;
    const status = fields.get("status")?.raw;
    const dependsOn = fields.get("depends_on")?.list ?? [];
    if (id === undefined || type === undefined) continue; // frontmatter.mjs's failure
    if (type === "layer") {
      layers.set(id, { path, status, dependsOn });
    } else if (type === "task") {
      tasks.set(id, { path, status, dependsOn, layer: dir });
    }
  }

  // --- referents resolve ----------------------------------------------
  for (const [id, layer] of layers) {
    for (const dep of layer.dependsOn) {
      if (!layers.has(dep)) {
        failures.push(
          `${layer.path}: layer ${id} depends on "${dep}", which is not a ` +
            `layer, a dangling reference`,
        );
      }
    }
  }
  for (const [id, task] of tasks) {
    for (const dep of task.dependsOn) {
      const depLayer = dep.split("/")[0];
      if (tasks.has(dep)) continue;
      if (!layers.has(depLayer)) {
        failures.push(
          `${task.path}: task ${id} depends on "${dep}", but no layer ` +
            `"${depLayer}" exists, a dangling reference`,
        );
      } else if (layers.get(depLayer).status !== "draft") {
        failures.push(
          `${task.path}: task ${id} depends on "${dep}", which does not ` +
            `exist although layer ${depLayer} is not draft. A non-draft ` +
            `layer's decomposition is final, so the referent must exist`,
        );
      }
      // else: unauthored task under a draft layer. Blocks, legal.
    }
  }

  // --- no cycles --------------------------------------------------------
  for (const [kind, nodes] of [
    ["layer", layers],
    ["task", tasks],
  ]) {
    const cycle = findCycle(nodes);
    if (cycle !== null) {
      failures.push(
        `${kind} dependency cycle: ${cycle.join(" -> ")}, which makes ` +
          `every member permanently unworkable`,
      );
    }
  }

  // --- the frontier -----------------------------------------------------
  const workable = [];
  const blocked = []; // { id, reason } for ready tasks only
  const inProgress = [];
  for (const [id, task] of tasks) {
    if (task.status === "in_progress") inProgress.push(id);
    if (task.status !== "ready") continue;
    const reasons = [];
    const layer = layers.get(task.layer);
    if (layer === undefined || layer.status !== "ready") {
      reasons.push(`layer ${task.layer} is not ready`);
    } else {
      for (const dep of layer.dependsOn) {
        if (layers.get(dep)?.status !== "done") {
          reasons.push(`layer gate: ${dep} is not done`);
        }
      }
    }
    for (const dep of task.dependsOn) {
      const depTask = tasks.get(dep);
      if (depTask === undefined) {
        reasons.push(`${dep} is unauthored`);
      } else if (depTask.status !== "done") {
        reasons.push(`${dep} is ${depTask.status}`);
      }
    }
    if (reasons.length === 0) workable.push(id);
    else blocked.push({ id, reasons });
  }
  workable.sort();
  blocked.sort((a, b) => a.id.localeCompare(b.id));
  inProgress.sort();

  return {
    failures,
    layerCount: layers.size,
    taskCount: tasks.size,
    workable,
    blocked,
    inProgress,
  };
}

export function printFrontier(result) {
  console.log("frontier (ready, all dependencies done):");
  if (result.workable.length === 0) {
    console.log("  (empty, nothing is workable right now)");
  }
  for (const id of result.workable) console.log(`  ${id}`);
  if (result.inProgress.length > 0) {
    console.log(`claimed (in_progress): ${result.inProgress.join(", ")}`);
  }
  for (const { id, reasons } of result.blocked) {
    console.log(`blocked: ${id} due to ${reasons.join("; ")}`);
  }
}

// Iterative DFS three-color cycle search over { id -> { dependsOn } };
// edges to nodes outside the map (unauthored tasks) are ignored.
function findCycle(nodes) {
  const state = new Map(); // id -> "open" | "closed"
  for (const start of nodes.keys()) {
    if (state.has(start)) continue;
    const stack = [[start, 0]];
    const pathStack = [];
    while (stack.length > 0) {
      const [id, edge] = stack[stack.length - 1];
      if (edge === 0) {
        state.set(id, "open");
        pathStack.push(id);
      }
      const deps = (nodes.get(id)?.dependsOn ?? []).filter((d) => nodes.has(d));
      if (edge < deps.length) {
        stack[stack.length - 1][1]++;
        const next = deps[edge];
        if (state.get(next) === "open") {
          return [...pathStack.slice(pathStack.indexOf(next)), next];
        }
        if (!state.has(next)) stack.push([next, 0]);
      } else {
        state.set(id, "closed");
        pathStack.pop();
        stack.pop();
      }
    }
  }
  return null;
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  // --no-frontier: validate only; checks/run.mjs passes it so the
  // frontier prints once, after every check, not mid-suite.
  const args = process.argv.slice(2).filter((a) => a !== "--no-frontier");
  const root = args[0] ?? "plans";
  const result = analyze(root);
  if (result.failures.length > 0) {
    for (const failure of result.failures) console.error(`FAIL ${failure}`);
    process.exit(1);
  }
  console.log(
    `plan-graph: ${result.layerCount} layers and ${result.taskCount} task ` +
      `files form a valid graph, with no cycles and no dangling references`,
  );
  if (!process.argv.includes("--no-frontier")) printFrontier(result);
}
