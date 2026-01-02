"use client";

import { useEffect, useMemo, useState } from "react";
import { Button } from "@/components/ui/button";
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useToast } from "@/hooks/use-toast";
import JSZip from "jszip";
import { ArrowLeft, Star, Youtube } from "lucide-react";
import { useEditor } from "./editor-context";
import { getProject, listFiles } from "@/lib/storage";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group";
import { Checkbox } from "@/components/ui/checkbox";
import { getSupabaseBrowserClient } from "@/lib/supabase";
import { SubmitWallpaperDialog } from "@/app/wallpapers/SubmitWallpaperDialog";

type ExportLicense = "none" | "cc-by-4.0" | "cc-by-sa-4.0" | "cc-by-nc-4.0";

async function loadLicenseText(license: ExportLicense): Promise<string | null> {
  if (license === "none") return null;

  const filenameMap: Record<Exclude<ExportLicense, "none">, string> = {
    "cc-by-4.0": "cc-by-4.0.txt",
    "cc-by-sa-4.0": "cc-by-sa-4.0.txt",
    "cc-by-nc-4.0": "cc-by-nc-4.0.txt",
  };

  const filename = filenameMap[license as Exclude<ExportLicense, "none">];
  if (!filename) return null;

  try {
    const resp = await fetch(`/licenses/${filename}`);
    if (!resp.ok) return null;
    const text = await resp.text();
    return text || null;
  } catch {
    return null;
  }
}

export function ExportDialog() {
  const { doc, flushPersist, cleanupAssets } = useEditor();
  const { toast } = useToast();
  const supabase = getSupabaseBrowserClient();

  const [exportOpen, setExportOpen] = useState(false);
  const [exportingTendies, setExportingTendies] = useState(false);
  const [exportView, setExportView] = useState<"select" | "success">("select");
  const [exportFilename, setExportFilename] = useState("");
  const [exportFormat, setExportFormat] = useState<"ca" | "tendies">("ca");
  const [exportLicense, setExportLicense] = useState<ExportLicense>("none");
  const [exportConfirmed, setExportConfirmed] = useState(false);
  const [isSubmitDialogOpen, setIsSubmitDialogOpen] = useState(false);
  const [username, setUsername] = useState<string>("");
  const [displayName, setDisplayName] = useState<string>("");
  const [isSignedIn, setIsSignedIn] = useState(false);
  const requiresLicenseConfirmation = exportLicense !== "none";

  const starMessage = useMemo(() => {
    const messages = [
      "Star this repo, make my day,\nIt helps the app in every way! 🌟",
      "A single star can light the way,\nSupport the code I've built today! 🚀",
      "Drop a star, don't walk away,\nIt keeps this project here to stay! 💪",
      "Give a star, don't delay,\nYou'll make my coder's day! 💫",
      "Star the repo, join the crew,\nIt means a lot, from me to you! 🤝",
    ];
    return messages[Math.floor(Math.random() * messages.length)];
  }, [exportView]);

  useEffect(() => {
    if (exportOpen && doc?.meta.name) {
      setExportFilename(doc.meta.name);
    }
  }, [exportOpen, doc?.meta.name]);

  useEffect(() => {
    const onKeyDown = (e: KeyboardEvent) => {
      const isMod = e.metaKey || e.ctrlKey;
      if (!isMod) return;
      const key = e.key.toLowerCase();
      if (key === "e") {
        e.preventDefault();
        setExportView("select");
        setExportOpen(true);
      }
    };
    window.addEventListener("keydown", onKeyDown);
    return () => window.removeEventListener("keydown", onKeyDown);
  }, []);

  useEffect(() => {
    let mounted = true;
    async function loadUser() {
      try {
        const { data } = await supabase.auth.getUser();
        const user = data.user;
        if (!user) {
          if (mounted) setIsSignedIn(false);
          return;
        }

        if (mounted) setIsSignedIn(true);

        const meta: any = user.user_metadata || {};
        const name = meta.full_name || meta.name || meta.username || user.email || "";
        if (mounted) setDisplayName(name as string);

        const {  profile } = await supabase
          .from("profiles")
          .select("username")
          .eq("id", user.id)
          .maybeSingle();
        if (mounted && profile?.username) setUsername(profile.username as string);
      } catch {}
    }
    loadUser();
    return () => {
      mounted = false;
    };
  }, [supabase]);

  // Bridge-aware download helper for Median/GoNative apps
  const downloadViaBridgeOrBrowser = (blob: Blob, nameSafe: string, ext: string) => {
    const reader = new FileReader();
    reader.readAsDataURL(blob);
    reader.onloadend = () => {
      const base64data = reader.result as string;
      const ua = navigator.userAgent.toLowerCase();
      const isApp = (window as any).median || (window as any).gonative || ua.includes("gonative") || ua.includes("median");

      if (isApp) {
        // Use modern Median JS API if available, else fallback to protocol
        if ((window as any).median?.share?.downloadFile) {
          (window as any).median.share.downloadFile({
            url: base64data,
            filename: `${nameSafe}${ext}`,
            open: true
          });
        } else {
          const bridgeUrl = `gonative://share/downloadFile?url=${encodeURIComponent(
            base64data,
          )}&filename=${encodeURIComponent(nameSafe)}${ext}`;
          window.location.href = bridgeUrl;
        }
      } else {
        const url = URL.createObjectURL(blob);
        const a = document.createElement("a");
        a.href = url;
        a.download = `${nameSafe}${ext}`;
        document.body.appendChild(a);
        a.click();
        a.remove();
        URL.revokeObjectURL(url);
      }
    };
  };

  const exportCA = async (downloadNameOverride?: string): Promise<boolean> => {
    try {
      if (!doc) return false;
      try {
        await flushPersist();
        await cleanupAssets(); 
      } catch {}
      const proj = await getProject(doc.meta.id);
      const baseName = (downloadNameOverride && downloadNameOverride.trim()) || proj?.name || doc.meta.name || "Project";
      const nameSafe = baseName.replace(/[^a-z0-9\-_]+/gi, "-");
      const folder = `${proj?.name || doc.meta.name || "Project"}.ca`;
      const allFiles = await listFiles(doc.meta.id, `${folder}/`);
      const outputZip = new JSZip();
      const isGyro = doc.meta.gyroEnabled ?? false;

      if (isGyro) {
        const wallpaperPrefix = `${folder}/Wallpaper.ca/`;
        for (const f of allFiles) {
          let rel: string | null = null;
          if (f.path.startsWith(wallpaperPrefix)) {
            rel = `Wallpaper.ca/${f.path.substring(wallpaperPrefix.length)}`;
          }
          if (!rel) continue;
          if (f.type === "text") outputZip.file(rel, String(f.data));
          else outputZip.file(rel, f.data as ArrayBuffer);
        }
      } else {
        const backgroundPrefix = `${folder}/Background.ca/`;
        const floatingPrefix = `${folder}/Floating.ca/`;
        for (const f of allFiles) {
          let rel: string | null = null;
          if (f.path.startsWith(backgroundPrefix)) rel = `Background.ca/${f.path.substring(backgroundPrefix.length)}`;
          else if (f.path.startsWith(floatingPrefix)) rel = `Floating.ca/${f.path.substring(floatingPrefix.length)}`;
          if (!rel) continue;
          if (f.type === "text") outputZip.file(rel, String(f.data));
          else outputZip.file(rel, f.data as ArrayBuffer);
        }
      }

      const licenseText = await loadLicenseText(exportLicense);
      if (licenseText) outputZip.file("LICENSE.txt", licenseText);

      const finalZipBlob = await outputZip.generateAsync({ type: "blob" });
      downloadViaBridgeOrBrowser(finalZipBlob, nameSafe, ".ca");
      return true;
    } catch (e) {
      console.error("Export failed", e);
      toast({ title: "Export failed", description: "Failed to export .ca file.", variant: "destructive" });
      return false;
    }
  };

  const exportTendies = async (downloadNameOverride?: string): Promise<boolean> => {
    try {
      setExportingTendies(true);
      if (!doc) return false;
      await flushPersist();
      await cleanupAssets();
      
      const proj = await getProject(doc.meta.id);
      const baseName = (downloadNameOverride && downloadNameOverride.trim()) || proj?.name || doc.meta.name || "Project";
      const nameSafe = baseName.replace(/[^a-z0-9\-_]+/gi, "-");
      const isGyro = doc.meta.gyroEnabled ?? false;

      const templateEndpoint = isGyro ? "/api/templates/gyro-tendies" : "/api/templates/tendies";
      const templateResponse = await fetch(templateEndpoint);
      if (!templateResponse.ok) throw new Error("Failed to fetch template");

      const templateArrayBuffer = await templateResponse.arrayBuffer();
      const templateZip = new JSZip();
      await templateZip.loadAsync(templateArrayBuffer);
      const outputZip = new JSZip();

      for (const [path, file] of Object.entries(templateZip.files)) {
        if (!file.dir) outputZip.file(path, await file.async("uint8array"));
      }

      const folder = `${proj?.name || doc.meta.name || "Project"}.ca`;
      const allFiles = await listFiles(doc.meta.id, `${folder}/`);

      if (isGyro) {
        const wallpaperPrefix = `${folder}/Wallpaper.ca/`;
        // FIX: The type here MUST include the 'data' key to avoid "Expression expected" error
        const caMap: Array<{ path: string;  Uint8Array | string }> = [];
        for (const f of allFiles) {
          if (f.path.startsWith(wallpaperPrefix)) {
            caMap.push({
              path: f.path.substring(wallpaperPrefix.length),
               f.type === "text" ? String(f.data) : new Uint8Array(f.data as ArrayBuffer),
            });
          }
        }
        const caFolderPath = "descriptors/99990000-0000-0000-0000-000000000000/versions/0/contents/7400.WWDC_2022-390w-844h@3x~iphone.wallpaper/wallpaper.ca";
        for (const file of caMap) outputZip.file(`${caFolderPath}/${file.path}`, file.data);
      } else {
        const backgroundPrefix = `${folder}/Background.ca/`;
        const floatingPrefix = `${folder}/Floating.ca/`;
        const caMap: Record<"background" | "floating", Array<{ path: string;  Uint8Array | string }>> = { background: [], floating: [] };
        for (const f of allFiles) {
          if (f.path.startsWith(backgroundPrefix)) {
            caMap.background.push({ path: f.path.substring(backgroundPrefix.length),  f.type === "text" ? String(f.data) : new Uint8Array(f.data as ArrayBuffer) });
          } else if (f.path.startsWith(floatingPrefix)) {
            caMap.floating.push({ path: f.path.substring(floatingPrefix.length),  f.type === "text" ? String(f.data) : new Uint8Array(f.data as ArrayBuffer) });
          }
        }
        for (const key of (["background", "floating"] as const)) {
          const caFolderPath = key === "floating" 
            ? "descriptors/09E9B685-7456-4856-9C10-47DF26B76C33/versions/1/contents/7400.WWDC_2022-390w-844h@3x~iphone.wallpaper/7400.WWDC_2022_Floating-390w-844h@3x~iphone.ca"
            : "descriptors/09E9B685-7456-4856-9C10-47DF26B76C33/versions/1/contents/7400.WWDC_2022-390w-844h@3x~iphone.wallpaper/7400.WWDC_2022_Background-390w-844h@3x~iphone.ca";
          for (const file of caMap[key]) outputZip.file(`${caFolderPath}/${file.path}`, file.data);
        }
      }

      const licenseText = await loadLicenseText(exportLicense);
      if (licenseText) outputZip.file("LICENSE.txt", licenseText);

      const finalZipBlob = await outputZip.generateAsync({ type: "blob" });
      downloadViaBridgeOrBrowser(finalZipBlob, nameSafe, ".tendies");

      toast({ title: "Export successful", description: `"${nameSafe}.tendies" downloaded.` });
      return true;
    } catch (e) {
      console.error("Tendies export failed", e);
      toast({ title: "Export failed", description: "Failed to export tendies file.", variant: "destructive" });
      return false;
    } finally {
      setExportingTendies(false);
    }
  };

  return (
    <div>
      <Button variant="secondary" disabled={!doc} onClick={() => { setExportView("select"); setExportOpen(true); }} className="px-3 sm:px-4">
        Export
      </Button>
      <Dialog open={exportOpen} onOpenChange={(v) => { setExportOpen(v); if (!v) setExportView("select"); }}>
        <DialogContent className="sm:max-w-md p-4">
          <DialogHeader className={exportView === "success" ? "flex items-center justify-start py-1" : "py-2"}>
            {exportView === "success" ? (
              <Button variant="ghost" className="h-8 w-auto px-2 gap-1 self-start" onClick={() => setExportView("select")}>
                <ArrowLeft className="h-4 w-4" /> Back
              </Button>
            ) : (
              <>
                <DialogTitle>Export</DialogTitle>
                <DialogDescription>Choose a filename, format, and license.</DialogDescription>
              </>
            )}
          </DialogHeader>
          <div className="relative overflow-hidden">
            <div className={`flex w-[200%] transition-transform duration-300 ease-out ${exportView === "select" ? "export-view-select" : "export-view-success"}`}>
              {/* Select View */}
              <div className={`w-1/2 px-0 ${exportView === "success" ? "h-0 overflow-hidden" : ""}`}>
                <div className="space-y-4">
                  <div className="space-y-1">
                    <Label htmlFor="export-filename">File name</Label>
                    <Input id="export-filename" value={exportFilename} onChange={(e) => setExportFilename(e.target.value)} placeholder={doc?.meta.name || "Project"} />
                  </div>
                  <div className="space-y-1">
                    <Label>Format</Label>
                    <ToggleGroup type="single" value={exportFormat} onValueChange={(v) => v && setExportFormat(v as "ca" | "tendies")} className="w-full">
                      <ToggleGroupItem value="ca" className="flex-1 text-xs sm:text-sm">.ca bundle</ToggleGroupItem>
                      <ToggleGroupItem value="tendies" className="flex-1 text-xs sm:text-sm">Tendies</ToggleGroupItem>
                    </ToggleGroup>
                  </div>
                  <div className="space-y-1">
                    <Label>License</Label>
                    <Select value={exportLicense} onValueChange={(v) => setExportLicense(v as ExportLicense)}>
                      <SelectTrigger className="w-full"><SelectValue placeholder="No license" /></SelectTrigger>
                      <SelectContent>
                        <SelectItem value="none">No license</SelectItem>
                        <SelectItem value="cc-by-nc-4.0">CC BY-NC 4.0 (Recommended)</SelectItem>
                        <SelectItem value="cc-by-4.0">CC BY 4.0</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2 pt-2">
                    <Button className="w-full" disabled={!doc || exportingTendies || (requiresLicenseConfirmation && !exportConfirmed)} onClick={async () => {
                      const base = exportFilename.trim() || doc?.meta.name || "Project";
                      const ok = exportFormat === "ca" ? await exportCA(base) : await exportTendies(base);
                      if (ok) setExportView("success");
                    }}>
                      {exportFormat === "ca" ? "Export .ca" : exportingTendies ? "Exporting..." : "Export tendies"}
                    </Button>
                  </div>
                </div>
              </div>
              {/* Success View */}
              <div className={`w-1/2 px-0 ${exportView === "select" ? "h-0 overflow-hidden" : ""}`}>
                <div className="pt-0 pb-4 flex flex-col items-center text-center gap-2.5">
                  <div className="text-xl font-semibold whitespace-pre-line text-primary">
                    {starMessage}
                  </div>
                  <div className="w-full max-w-md text-left space-y-3 text-sm">
                    <div className="flex gap-3 border rounded-md px-4 py-3">
                      <div className="font-bold">1. Watch Tutorial</div>
                      <a href="https://www.youtube.com/watch?v=nSBQIwAaAEc" target="_blank" className="text-xs flex items-center gap-1 text-blue-500 underline"><Youtube className="h-3 w-3" /> Watch</a>
                    </div>
                    <div className="flex gap-3 border rounded-md px-4 py-3">
                      <div className="font-bold">2. Test</div>
                      <div>Apply the wallpaper using Nugget or Pocket Poster.</div>
                    </div>
                    <div className="flex gap-3 border rounded-md px-4 py-3">
                      <div className="font-bold">3. Showcase</div>
                      <button onClick={() => setIsSubmitDialogOpen(true)} className="text-xs text-blue-500 underline">Submit to Gallery</button>
                    </div>
                  </div>
                  <div className="flex gap-2 pt-4">
                    <a href="https://github.com/NightVibes3/CAPlayground" target="_blank" className="inline-flex items-center gap-2 border px-4 py-2 rounded-md text-sm hover:bg-muted">
                      <Star className="h-4 w-4" /> Star Repo
                    </a>
                    <Button onClick={() => setExportOpen(false)}>Done</Button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </DialogContent>
      </Dialog>
      <SubmitWallpaperDialog open={isSubmitDialogOpen} onOpenChange={setIsSubmitDialogOpen} username={username || displayName || "Anonymous"} isSignedIn={isSignedIn} />
    </div>
  );
}

export default ExportDialog;
