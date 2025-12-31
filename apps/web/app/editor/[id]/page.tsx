"use client";

export const runtime = 'nodejs';
export const dynamic = 'force-dynamic';

import { useEffect, useRef, useState } from "react";
import { motion, AnimatePresence, useDragControls } from "framer-motion";
import { useLocalStorage } from "@/hooks/use-local-storage";
import { useParams, useRouter } from "next/navigation";
import { EditorProvider } from "@/components/editor/editor-context";
import { MenuBar } from "@/components/editor/menu-bar";
import { LayersPanel } from "@/components/editor/layers-panel";
import { StatesPanel } from "@/components/editor/states-panel";
import { Inspector } from "@/components/editor/inspector";
import { CanvasPreview } from "@/components/editor/canvas-preview";
import { MobileBottomBar } from "@/components/editor/mobile-bottom-bar";
import { Eye, EyeOff } from "lucide-react";
import { cn } from "@/lib/utils";
import EditorOnboarding from "@/components/editor/onboarding";
import { BrowserWarning } from "@/components/editor/browser-warning";
import { getProject } from "@/lib/storage";
import { TimelineProvider } from "@/context/TimelineContext";

export default function EditorPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const projectId = params?.id;
  const [meta, setMeta] = useState<{ id: string; name: string; width: number; height: number; background?: string } | null>(null);
  const [leftWidth, setLeftWidth] = useLocalStorage<number>("caplay_panel_left_width", 320);
  const [rightWidth, setRightWidth] = useLocalStorage<number>("caplay_panel_right_width", 400);
  const [statesHeight, setStatesHeight] = useLocalStorage<number>("caplay_panel_states_height", 350);
  const [autoClosePanels] = useLocalStorage<boolean>("caplay_settings_auto_close_panels", true);
  const leftPaneRef = useRef<HTMLDivElement | null>(null);
  const [showLeft, setShowLeft] = useState(true);
  const [showRight, setShowRight] = useState(false);
  const containerRef = useRef<HTMLDivElement | null>(null);
  const dragControls = useDragControls();

  type PanelKey = 'layers_states' | 'inspector';
  const [mobilePanelScreen, setMobilePanelScreen] = useState<PanelKey>('layers_states');
  const [mobileView, setMobileView] = useState<'canvas' | 'panels'>('canvas');
  const [isPeeking, setIsPeeking] = useState(false);
  const [detent, setDetent] = useState<'full' | 'half'>('full');

  // Reset detent when opening panels
  useEffect(() => {
    if (mobileView === 'panels') {
      setDetent('full');
    }
  }, [mobileView]);

  // Enforce mobile-only behavior: lock scroll in canvas view
  useEffect(() => {
    const hasOpenDialog = () => document.querySelector('[role="dialog"]') !== null;
    if (mobileView === 'canvas' && !hasOpenDialog()) {
      document.body.style.overflow = 'hidden';
      document.body.style.position = 'fixed';
      document.body.style.width = '100%';
      document.body.style.height = '100%';
    } else {
      document.body.style.overflow = '';
      document.body.style.position = '';
      document.body.style.width = '';
      document.body.style.height = '';
    }
    return () => {
      document.body.style.overflow = '';
      document.body.style.position = '';
    };
  }, [mobileView]);

  useEffect(() => {
    if (!projectId) return;
    (async () => {
      try {
        const p = await getProject(projectId);
        if (!p) {
          router.replace("/projects");
          return;
        }
        setMeta({ id: p.id, name: p.name, width: p.width ?? 390, height: p.height ?? 844 });
      } catch {
        router.replace("/projects");
      }
    })();
  }, [projectId]);

  if (!projectId || !meta) return null;

  return (
    <EditorProvider projectId={projectId} initialMeta={meta}>
      <TimelineProvider>
        <BrowserWarning />
        {/* Mobile-only wrapper: centers the app on desktop */}
        <div className="flex flex-col items-center justify-center min-h-dvh bg-muted/20">
          <div className="flex flex-col h-dvh w-full max-w-[500px] bg-background shadow-2xl relative" ref={containerRef}>
            <MenuBar
              projectId={projectId}
              showLeft={mobileView === 'panels' && mobilePanelScreen === 'layers_states'}
              showRight={mobileView === 'panels' && mobilePanelScreen === 'inspector'}
              toggleLeft={() => {
                if (mobileView === 'panels' && mobilePanelScreen === 'layers_states') {
                  setMobileView('canvas');
                } else {
                  setMobileView('panels');
                  setMobilePanelScreen('layers_states');
                }
              }}
              toggleRight={() => {
                if (mobileView === 'panels' && mobilePanelScreen === 'inspector') {
                  setMobileView('canvas');
                } else {
                  setMobileView('panels');
                  setMobilePanelScreen('inspector');
                }
              }}
              leftWidth={leftWidth}
              rightWidth={rightWidth}
              setLeftWidth={setLeftWidth}
              setRightWidth={setRightWidth}
              setStatesHeight={setStatesHeight}
            />
            <div className="flex-1 overflow-hidden relative">
              <div className="h-full w-full flex flex-col relative">
                {/* Always show canvas in background - truly edge-to-edge */}
                <div className={`min-h-0 flex-1 transition-all duration-300 ${mobileView === 'panels' ? 'scale-[0.96] brightness-50 blur-[2px]' : ''}`}>
                  <CanvasPreview />
                </div>

                <AnimatePresence>
                  {mobileView === 'panels' && (
                    <motion.div
                      initial={{ y: "100%" }}
                      animate={{ 
                        y: detent === 'full' ? (isPeeking ? 40 : 0) : "45%",
                        opacity: isPeeking ? 0.2 : 1,
                        scale: isPeeking ? 0.98 : 1,
                      }}
                      exit={{ y: "100%" }}
                      drag="y"
                      dragControls={dragControls}
                      dragListener={false}
                      dragConstraints={{ top: 0, bottom: 800 }}
                      dragElastic={0.1}
                      onDragEnd={(_, info) => {
                        const y = info.offset.y;
                        const velocity = info.velocity.y;
                        
                        // Swipe down force: close
                        if (velocity > 400 || y > 350) {
                          setMobileView('canvas');
                        } 
                        // Swipe up force: full
                        else if (velocity < -400) {
                          setDetent('full');
                        }
                        // Position based snapping
                        else if (y > 150) {
                          setDetent('half');
                        } else {
                          setDetent('full');
                        }
                      }}
                      transition={{ 
                        type: "spring", 
                        damping: 30, 
                        stiffness: 300,
                        mass: 0.8
                      }}
                      className={cn(
                        "absolute inset-0 z-50 flex flex-col pt-10",
                        isPeeking && "pointer-events-none"
                      )}
                    >
                      {/* iOS Sheet Background with Glass Effect */}
                      <div className="flex-1 ios-glass shadow-2xl rounded-t-[32px] overflow-hidden flex flex-col border-t border-border/50">
                        {/* iOS Sheet Header with Grabber and Peek Toggle */}
                        <div className="w-full flex items-center justify-between px-6 py-3 shrink-0">
                          <div className="w-10" /> {/* Spacer */}
                          <div 
                            className="w-20 h-2 bg-muted-foreground/20 rounded-full cursor-grab active:cursor-grabbing hover:bg-muted-foreground/30 transition-colors p-3 -m-3" 
                            onPointerDown={(e) => dragControls.start(e)}
                          />
                          <button
                            onClick={() => setIsPeeking(!isPeeking)}
                            className="w-10 h-10 flex items-center justify-center rounded-full bg-muted/20 active:bg-muted/40 transition-colors pointer-events-auto"
                            aria-label="Peek behind panels"
                          >
                            {isPeeking ? <EyeOff className="h-5 w-5 text-ios-blue" /> : <Eye className="h-5 w-5 opacity-60" />}
                          </button>
                        </div>

                        <div className="flex-1 overflow-auto px-4 pb-40">
                          {mobilePanelScreen === 'layers_states' ? (
                            <div className="flex flex-col gap-4 min-h-0">
                              <div className="flex flex-col gap-2">
                                <h1 className="text-2xl font-bold px-2">Layers</h1>
                                <LayersPanel />
                              </div>
                              <div className="flex flex-col gap-2 pt-4">
                                <h1 className="text-2xl font-bold px-2">States</h1>
                                <StatesPanel />
                              </div>
                            </div>
                          ) : (
                            <div className="flex flex-col gap-2 h-full">
                              <h1 className="text-2xl font-bold px-2">Inspector</h1>
                              <Inspector />
                            </div>
                          )}
                        </div>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>

                <MobileBottomBar
                  mobileView={mobileView}
                  setMobileView={setMobileView}
                  mobilePanelScreen={mobilePanelScreen}
                  setMobilePanelScreen={setMobilePanelScreen}
                />
              </div>
            </div>
            <EditorOnboarding showLeft={mobileView === 'panels'} showRight={mobileView === 'panels'} />
          </div>
        </div>
      </TimelineProvider>
    </EditorProvider>
  );
}
