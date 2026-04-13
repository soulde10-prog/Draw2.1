
export function createProject() {
  return {
    id: crypto.randomUUID(),
    name: "Untitled",
    roofs: [],
    meta: { version: 1 }
  };
}

export function addRoof(project, roof) {
  return {
    ...project,
    roofs: [
      ...project.roofs,
      { id: crypto.randomUUID(), ...roof }
    ]
  };
}
