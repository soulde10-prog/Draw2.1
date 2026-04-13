
export function snap(value, grid) {
  return Math.round(value / grid) * grid;
}
