import { useEffect, useRef, useState } from "react";

export default function Home() {
  const [logs, setLogs] = useState([]);
  const wsRef = useRef(null);

  useEffect(() => {
    const url = process.env.NEXT_PUBLIC_WSS_URL || "wss://api.pirtolx.tech/ws/v4";
    function addLog(txt) {
      setLogs(l => [new Date().toISOString() + " — " + txt, ...l].slice(0, 200));
    }

    function tryConnect() {
      addLog("Connecting to " + url);
      const ws = new WebSocket(url);
      wsRef.current = ws;

      ws.onopen = () => addLog("WS OPEN");
      ws.onmessage = ev => addLog("RECV: " + ev.data);
      ws.onclose = () => {
        addLog("WS CLOSED — reconnect in 3s");
        setTimeout(tryConnect, 3000);
      };
      ws.onerror = () => {
        addLog("WS ERROR");
        ws.close();
      };
    }

    tryConnect();
    return () => wsRef.current?.close();
  }, []);

  return (
    <main style={{ padding: 24, fontFamily: "Inter, system-ui" }}>
      <h1>Pirtolx UI V4 — Front minimal</h1>
      <p>Connected to <code>{process.env.NEXT_PUBLIC_WSS_URL || "wss://api.pirtolx.tech/ws/v4"}</code></p>
      <div style={{ display: "flex", gap: 16 }}>
        <section style={{flex:1}}>
          <h2>Logs</h2>
          <div style={{height:400, overflow:'auto', background:'#111', color:'#ddd', padding:12}}>
            {logs.map((l,i)=>(<div key={i} style={{fontFamily:'monospace', fontSize:12}}>{l}</div>))}
          </div>
        </section>
      </div>
    </main>
  );
}
