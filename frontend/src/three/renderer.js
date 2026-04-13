
import * as THREE from "three";

export function buildRoof(roof) {
  const geo = new THREE.BoxGeometry(roof.width, 1, roof.length);
  const mat = new THREE.MeshStandardMaterial({ color: "brown" });
  return new THREE.Mesh(geo, mat);
}
