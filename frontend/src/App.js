
import React, { useEffect, useState } from "react";
import { subscribe } from "./canvas/arch-engine";

export default function App() {
  const [project, setProject] = useState(null);

  useEffect(() => {
    subscribe(setProject);
  }, []);

  return (
    <div>
      <h1>Roofing Platform V2</h1>
      <pre>{JSON.stringify(project, null, 2)}</pre>
    </div>
  );
}
