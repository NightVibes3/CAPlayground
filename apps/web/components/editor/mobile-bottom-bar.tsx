"use client";

import { ChevronDown, ChevronUp, ArrowUpDown, Layers as LayersIcon, Check, Plus, X, CircleDot } from "lucide-react";
import { useEditor } from "./editor-context";
import { useLocalStorage } from "@/hooks/use-local-storage";
import { useRef, useState, useEffect } from "react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import { Label } from "@/components/ui/label";
import { cn } from "@/lib/utils";

type MobileBottomBarProps = {
  mobileView: 'canvas' | 'panels';
  setMobileView: (view: 'canvas' | 'panels') => void;
  mobilePanelScreen: 'layers_states' | 'inspector';
  setMobilePanelScreen: (screen: 'layers_states' | 'inspector') => void;
};

export function MobileBottomBar({
  mobileView,
  setMobileView,
  mobilePanelScreen,
  setMobilePanelScreen
}: MobileBottomBarProps) {
  const {
    doc,
    activeCA,
    setActiveCA,
    addTextLayer,
    addImageLayerFromFile,
    addShapeLayer,
    addGradientLayer,
    addVideoLayerFromFile,
    addEmitterLayer,
    addTransformLayer,
    setActiveState,
  } = useEditor();
  const isGyro = doc?.meta.gyroEnabled ?? false;
  const [showBackground, setShowBackground] = useLocalStorage<boolean>("caplay_preview_show_background", true);
  const [statesOpen, setStatesOpen] = useState(false);
  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const videoInputRef = useRef<HTMLInputElement | null>(null);
  const containerRef = useRef<HTMLDivElement | null>(null);

  const key = doc?.activeCA ?? 'floating';
  const current = doc?.docs?.[key];
  const states = current?.states ?? [];
  const activeState = current?.activeState || 'Base State';

  const [showStates, setShowStates] = useState(true);
  const [showAddLayer, setShowAddLayer] = useState(true);

  useEffect(() => {
    const checkWidth = () => {
      if (!containerRef.current) return;

      const SIDE_MARGIN = 16;
      const GAP = 12;
      const BUTTON_TOGGLE = 105;
      const BUTTON_CA = 130;
      const BUTTON_ICON = 40;

      const screenWidth = window.innerWidth;
      const availableWidth = screenWidth - (SIDE_MARGIN * 2);
      const width4Buttons = BUTTON_TOGGLE + GAP + BUTTON_CA + GAP + BUTTON_ICON + GAP + BUTTON_ICON;
      const width3Buttons = BUTTON_TOGGLE + GAP + BUTTON_CA + GAP + BUTTON_ICON;
      const width2Buttons = BUTTON_TOGGLE + GAP + BUTTON_CA;

      if (availableWidth >= width4Buttons) {
        setShowStates(true);
        setShowAddLayer(true);
      } else if (availableWidth >= width3Buttons) {
        setShowStates(false);
        setShowAddLayer(true);
      } else if (availableWidth >= width2Buttons) {
        setShowStates(false);
        setShowAddLayer(false);
      }
    };

    checkWidth();
    window.addEventListener('resize', checkWidth);
    return () => window.removeEventListener('resize', checkWidth);
  }, []);

  return (
    <div className="fixed bottom-0 left-0 right-0 z-50 px-4 pb-[env(safe-area-inset-bottom,16px)] pointer-events-none flex justify-center">
      <div
        ref={containerRef}
        className="w-full max-w-[440px] h-16 ios-glass border border-border/50 shadow-2xl rounded-[32px] px-6 flex items-center justify-between backdrop-blur-2xl pointer-events-auto"
      >
        <button
          className={cn(
            "flex flex-col items-center gap-1 transition-all ios-active-scale",
            mobileView === 'canvas' ? "text-ios-blue" : "text-muted-foreground"
          )}
          onClick={() => setMobileView('canvas')}
        >
          <CircleDot className="h-6 w-6" />
          <span className="text-[10px] font-medium">Canvas</span>
        </button>

        <button
          className={cn(
            "flex flex-col items-center gap-1 transition-all ios-active-scale",
            (mobileView === 'panels' && mobilePanelScreen === 'layers_states') ? "text-ios-blue" : "text-muted-foreground"
          )}
          onClick={() => {
            setMobileView('panels');
            setMobilePanelScreen('layers_states');
          }}
        >
          <LayersIcon className="h-6 w-6" />
          <span className="text-[10px] font-medium">Layers</span>
        </button>

        {showAddLayer && (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button
                className="flex flex-col items-center gap-1 transition-all ios-active-scale text-muted-foreground relative"
                aria-label="Add Layer"
              >
                <div className="bg-ios-blue text-white rounded-full p-2 shadow-lg border-2 border-background">
                  <Plus className="h-6 w-6" />
                </div>
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="center" side="top" className="mb-4 ios-glass rounded-2xl p-2 w-48">
              <DropdownMenuItem className="rounded-xl py-3" onSelect={() => addTextLayer()}>Text Layer</DropdownMenuItem>
              <DropdownMenuItem className="rounded-xl py-3" onSelect={() => addShapeLayer("rect")}>Basic Layer</DropdownMenuItem>
              <DropdownMenuItem className="rounded-xl py-3" onSelect={() => addGradientLayer()}>Gradient Layer</DropdownMenuItem>
              <DropdownMenuItem className="rounded-xl py-3" onSelect={() => fileInputRef.current?.click()}>Image Layer…</DropdownMenuItem>
              <DropdownMenuItem className="rounded-xl py-3" onSelect={() => videoInputRef.current?.click()}>Video Layer…</DropdownMenuItem>
              <DropdownMenuItem className="rounded-xl py-3" onSelect={() => addEmitterLayer()}>Emitter Layer</DropdownMenuItem>
              {isGyro && (
                <DropdownMenuItem className="rounded-xl py-3" onSelect={() => addTransformLayer()}>Transform Layer</DropdownMenuItem>
              )}
            </DropdownMenuContent>
          </DropdownMenu>
        )}

        <button
          className={cn(
            "flex flex-col items-center gap-1 transition-all ios-active-scale",
            (mobileView === 'panels' && mobilePanelScreen === 'inspector') ? "text-ios-blue" : "text-muted-foreground"
          )}
          onClick={() => {
            setMobileView('panels');
            setMobilePanelScreen('inspector');
          }}
        >
          <ChevronUp className="h-6 w-6" />
          <span className="text-[10px] font-medium">Inspector</span>
        </button>

        {!isGyro && (
          <DropdownMenu>
            <DropdownMenuTrigger asChild>
              <button
                className="flex flex-col items-center gap-1 transition-all ios-active-scale text-muted-foreground"
              >
                <ArrowUpDown className="h-6 w-6" />
                <span className="text-[10px] font-medium">{activeCA === 'floating' ? 'Floating' : 'BG'}</span>
              </button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end" side="top" className="w-80 p-2 mb-4 ios-glass rounded-2xl">
              {/* Same content as before but styled for iOS */}
              <DropdownMenuLabel className="text-sm font-semibold">Animation Area</DropdownMenuLabel>
              <DropdownMenuSeparator />
              <div className="grid gap-2 p-1">
                <Button
                  variant="ghost"
                  onClick={() => { setActiveCA('background'); }}
                  className={cn("w-full justify-start py-6 rounded-xl", activeCA === 'background' && "bg-muted")}
                >
                  <div className="flex items-center gap-3">
                    <LayersIcon className="h-4 w-4" />
                    <div className="flex-1 text-left">
                      <div className="font-semibold">Background</div>
                      <div className="text-[10px] opacity-70">Appears behind the clock.</div>
                    </div>
                    {activeCA === 'background' && <Check className="h-4 w-4 text-ios-blue" />}
                  </div>
                </Button>
                <Button
                  variant="ghost"
                  onClick={() => { setActiveCA('floating'); }}
                  className={cn("w-full justify-start py-6 rounded-xl", activeCA === 'floating' && "bg-muted")}
                >
                  <div className="flex items-center gap-3">
                    <LayersIcon className="h-4 w-4" />
                    <div className="flex-1 text-left">
                      <div className="font-semibold">Floating</div>
                      <div className="text-[10px] opacity-70">Appears over the clock.</div>
                    </div>
                    {activeCA === 'floating' && <Check className="h-4 w-4 text-ios-blue" />}
                  </div>
                </Button>
              </div>
            </DropdownMenuContent>
          </DropdownMenu>
        )}

        <input
          ref={fileInputRef}
          type="file"
          accept="image/png,image/jpeg,image/jpg,image/webp,image/bmp,image/svg+xml"
          multiple
          title="Upload Image"
          className="hidden"
          onChange={async (e) => {
            const files = Array.from(e.target.files || []);
            if (!files.length) return;
            const imageFiles = files.filter(f => !(/image\/gif/i.test(f.type) || /\.gif$/i.test(f.name || '')));
            for (const file of imageFiles) {
              try { await addImageLayerFromFile(file); } catch { }
            }
            e.target.value = '';
          }}
        />
        <input
          ref={videoInputRef}
          type="file"
          accept="video/mp4,video/quicktime,video/x-m4v,image/gif"
          title="Upload Video"
          className="hidden"
          onChange={async (e) => {
            const file = e.target.files?.[0];
            if (file) {
              try { await addVideoLayerFromFile(file); } catch { }
            }
            e.target.value = '';
          }}
        />
      </div>
    </div>
  );
}
