
import { createProject, addRoof } from "../../../shared/model-core";

let project = createProject();
let listeners = [];

export function getProject() { return project; }

export function subscribe(fn) { listeners.push(fn); }

function emit() { listeners.forEach(f => f(project)); }

export function addRoofToModel(roof) {
  project = addRoof(project, roof);
  emit();
}
