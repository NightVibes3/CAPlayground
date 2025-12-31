"use client";

import { useEffect, useMemo, useState } from "react";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { TriangleAlert } from "lucide-react";

function isOfficialHost(hostname: string): boolean {
  if (hostname === "127.0.0.1" || hostname === "[::1]") return true;
  const baseDomains = [
    "localhost",
    "vercel.app",
    "caplayground.enkei64.xyz",
    "caplayground.netlify.app",
    "caplayground.squair.xyz",
    "caplayground.kittycat.boo"
  ];
  return baseDomains.some((base) => hostname === base || hostname.endsWith(`.${base}`));
}

export function UnofficialDomainBanner() {
  const [show, setShow] = useState(false);

  useEffect(() => {
    if (typeof window === "undefined") return;
    const host = window.location.hostname || "";
    const key = `caplay_unofficial_dismissed:${host}`;
    const dismissed = localStorage.getItem(key) === "1";
    const shouldShow = !isOfficialHost(host) && !dismissed;
    setShow(shouldShow);
  }, []);

  if (!show) return null;

  const handleDismiss = () => {
    if (typeof window === "undefined") return;
    const host = window.location.hostname || "";
    const key = `caplay_unofficial_dismissed:${host}`;
    try {
      localStorage.setItem(key, "1");
    } catch { }
    setShow(false);
  };

  return (
    <div className="sticky top-0 z-[100]">
      <Alert variant="destructive" className="rounded-none border-0">
        <TriangleAlert />
        <AlertTitle>Unofficial domain</AlertTitle>
        <AlertDescription>
          You are visiting this site on an unofficial domain. For the official site, please use
          {" "}
          <a className="underline font-medium" href="https://caplayground.vercel.app" target="_blank" rel="noreferrer noopener">caplayground.vercel.app</a>
        </AlertDescription>
        <button
          type="button"
          className="absolute right-2 top-2 text-muted-foreground hover:text-foreground z-10 p-1"
          aria-label="Dismiss"
          onClick={handleDismiss}
        >
          ✕
        </button>
      </Alert>
    </div>
  );
}

export default UnofficialDomainBanner;
