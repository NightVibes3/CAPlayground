"use client";

import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import { useEditor } from "../editor-context";
import { useEffect, useMemo, useState } from "react";
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";
import { SquareSlash, Box, Layers, Palette, Type, Image as ImageIcon, Play, PanelLeft, PanelTop, PanelRight, Video, Smartphone, Blend, Cog, Filter, GripVertical } from "lucide-react";
import { cn } from "@/lib/utils";
import { useLocalStorage } from "@/hooks/use-local-storage";
import { round2, fmt2, fmt0, type TabId } from "./types";
import { GeometryTab } from "./tabs/GeometryTab";
import { CompositingTab } from "./tabs/CompositingTab";
import { ContentTab } from "./tabs/ContentTab";
import { TextTab } from "./tabs/TextTab";
import { GradientTab } from "./tabs/GradientTab";
import { ImageTab } from "./tabs/ImageTab";
import { VideoTab } from "./tabs/VideoTab";
import { AnimationsTab } from "./tabs/AnimationsTab";
import { GyroTab } from "./tabs/GyroTab";
import { EmitterTab } from "./tabs/EmitterTab";
import { ReplicatorTab } from "./tabs/ReplicatorTab";
import { FiltersTab } from "./tabs/FiltersTab";
import { IOSListGroup, IOSListItem } from "@/components/ui/ios-list-group";
import { MobileStepper } from "@/components/ui/mobile-stepper";
import { findById } from "@/lib/editor/layer-utils";
import { useTimeline } from "@/context/TimelineContext";

export function Inspector() {
  const { doc, setDoc, updateLayer, updateLayerTransient, replaceImageForLayer, addEmitterCellImage, animatedLayers, selectLayer } = useEditor();
  const { isPlaying } = useTimeline();
  const [sidebarPosition, setSidebarPosition] = useLocalStorage<'left' | 'top' | 'right'>('caplay_inspector_tab_position', 'left');

  const key = doc?.activeCA ?? 'floating';
  const current = doc?.docs?.[key];
  const isRootSelected = current?.selectedId === '__root__';
  const selectedBase = current ? (isRootSelected ? undefined : findById(current.layers, current.selectedId)) : undefined;

  const selectedAnimated = useMemo(() => {
    if (!isPlaying || !animatedLayers.length || !current?.selectedId) return null;
    return findById(animatedLayers, current.selectedId);
  }, [isPlaying, animatedLayers, current?.selectedId]);

  const [inputs, setInputs] = useState<Record<string, string>>({});
  const selKey = selectedBase ? selectedBase.id : "__none__";

  useEffect(() => {
    setInputs({});
  }, [selKey]);

  const getBuf = (key: string, fallback: string): string => {
    const bufKey = `${selKey}:${key}`;
    return inputs[bufKey] !== undefined ? inputs[bufKey] : fallback;
  };

  const setBuf = (key: string, val: string) => {
    const bufKey = `${selKey}:${key}`;
    setInputs((prev) => ({ ...prev, [bufKey]: val }));
  };

  const clearBuf = (key: string) => {
    const bufKey = `${selKey}:${key}`;
    setInputs((prev) => {
      const next = { ...prev } as any;
      delete next[bufKey];
      return next;
    });
  };

  const selected = (() => {
    if (!current || !selectedBase) return selectedBase;

    if (selectedAnimated) return selectedAnimated;

    const state = current.activeState;
    if (!state || state === 'Base State') return selectedBase;
    const eff: any = structuredClone(selectedBase);
    const ovs = (current.stateOverrides || {})[state] || [];
    const me = ovs.filter(o => o.targetId === eff.id);
    for (const o of me) {
      const kp = (o.keyPath || '').toLowerCase();
      const v = o.value as number | string;
      if (kp === 'position.x' && typeof v === 'number') eff.position.x = v;
      else if (kp === 'position.y' && typeof v === 'number') eff.position.y = v;
      else if (kp === 'zposition' && typeof v === 'number') eff.zPosition = v;
      else if (kp === 'bounds.size.width' && typeof v === 'number') eff.size.w = v;
      else if (kp === 'bounds.size.height' && typeof v === 'number') eff.size.h = v;
      else if (kp === 'transform.rotation.z' && typeof v === 'number') eff.rotation = v as number;
      else if (kp === 'transform.rotation.x' && typeof v === 'number') eff.rotationX = v as number;
      else if (kp === 'transform.rotation.y' && typeof v === 'number') eff.rotationY = v as number;
      else if (kp === 'opacity' && typeof v === 'number') eff.opacity = v as number;
      else if (kp === 'cornerradius' && typeof v === 'number') eff.cornerRadius = v as number;
    }
    return eff;
  })();

  const {
    disablePosX,
    disablePosY,
    disablePosZ,
    disableRotX,
    disableRotY,
    disableRotZ,
  } = useMemo(() => {
    const a: any = (selectedBase as any)?.animations || {};
    const enabled = !!a.enabled;
    const kp: string = a.keyPath || '';
    const hasValues = Array.isArray(a.values) && a.values.length > 0;
    const on = (cond: boolean) => enabled && hasValues && cond;
    return {
      disablePosX: on(kp === 'position' || kp === 'position.x'),
      disablePosY: on(kp === 'position' || kp === 'position.y'),
      disablePosZ: on(kp === 'zPosition'),
      disableRotX: selectedBase?.type === 'emitter' || on(kp === 'transform.rotation.x'),
      disableRotY: selectedBase?.type === 'emitter' || on(kp === 'transform.rotation.y'),
      disableRotZ: on(kp === 'transform.rotation.z'),
    };
  }, [selectedBase]);

  const [activeTab, setActiveTab] = useState<TabId>('geometry');

  const tabs = useMemo(() => {
    let baseTabs = [
      { id: 'geometry' as TabId, icon: Box, label: 'Geometry' },
      { id: 'compositing' as TabId, icon: Layers, label: 'Compositing' },
      { id: 'content' as TabId, icon: Palette, label: 'Content' },
    ];
    if (selected?.type === 'text') {
      baseTabs.push({ id: 'text' as TabId, icon: Type, label: 'Text' });
    }
    if (selected?.type === 'gradient') {
      baseTabs.push({ id: 'gradient' as TabId, icon: Blend, label: 'Gradient' });
    }
    if (selected?.type === 'image') {
      baseTabs.push({ id: 'image' as TabId, icon: ImageIcon, label: 'Image' });
    }
    if (selected?.type === 'video') {
      baseTabs.push({ id: 'video' as TabId, icon: Video, label: 'Video' });
    }
    if (selected?.type !== 'video') {
      baseTabs.push({ id: 'animations' as TabId, icon: Play, label: 'Animations' });
    }
    if (doc?.meta.gyroEnabled && selected?.type === 'transform') {
      baseTabs.push({ id: 'gyro' as TabId, icon: Smartphone, label: 'Gyro (Parallax)' });
    }
    if (selected?.type === 'emitter') {
      baseTabs = [
        { id: 'geometry' as TabId, icon: Box, label: 'Geometry' },
        { id: 'compositing' as TabId, icon: Layers, label: 'Compositing' },
        { id: 'emitter' as TabId, icon: Cog, label: 'Emitter' },
      ]
    }
    if (selected?.type === 'replicator') {
      baseTabs = [
        { id: 'geometry' as TabId, icon: Box, label: 'Geometry' },
        { id: 'compositing' as TabId, icon: Layers, label: 'Compositing' },
        { id: 'replicator' as TabId, icon: Cog, label: 'Replicator' },
      ]
    }
    baseTabs.push({ id: 'filters' as TabId, icon: Filter, label: 'Filters' });
    return baseTabs;
  }, [selected?.type, doc?.meta.gyroEnabled]);

  useEffect(() => {
    if (selected?.type === 'text' && (['gradient', 'image', 'video', 'emitter', 'gyro'].includes(activeTab))) {
      setActiveTab('text');
    } else if (selected?.type === 'gradient' && (['text', 'image', 'video', 'emitter', 'gyro'].includes(activeTab))) {
      setActiveTab('gradient');
    } else if (selected?.type === 'image' && (['text', 'gradient', 'video', 'emitter', 'gyro'].includes(activeTab))) {
      setActiveTab('image');
    } else if (selected?.type === 'video' && (['animations', 'text', 'gradient', 'image', 'emitter', 'replicator', 'gyro'].includes(activeTab))) {
      setActiveTab('video');
    } else if (!['text', 'emitter', 'replicator', 'gradient', 'image', 'video', 'transform'].includes(selected?.type) && ['text', 'gradient', 'image', 'video', 'emitter', 'replicator', 'gyro'].includes(activeTab)) {
      setActiveTab('geometry');
    } else if (selected?.type === 'emitter' && (['animations', 'text', 'gradient', 'image', 'video', 'content', 'replicator', 'gyro'].includes(activeTab))) {
      setActiveTab('emitter');
    } else if (selected?.type === 'replicator' && (['animations', 'text', 'gradient', 'image', 'video', 'content', 'emitter', 'gyro'].includes(activeTab))) {
      setActiveTab('replicator');
    } else if (selected?.type === 'transform' && (['text', 'gradient', 'image', 'video', 'emitter', 'replicator'].includes(activeTab))) {
      setActiveTab('gyro');
    }
  }, [selected?.type, activeTab]);

  if (isRootSelected) {
    const widthVal = doc?.meta.width ?? 0;
    const heightVal = doc?.meta.height ?? 0;
    const gf = (doc?.meta as any)?.geometryFlipped ?? 0;
    return (
      <div className="h-full flex flex-col overflow-y-auto">
        {/* Helpful intro for mobile */}
        <div className="px-4 pt-2 pb-1">
          <p className="text-[15px] text-muted-foreground leading-relaxed">
            Configure your canvas size and coordinate system below.
          </p>
        </div>

        <IOSListGroup header="Canvas Size">
          <div className="p-3 bg-card space-y-3">
            <MobileStepper
              label="Width"
              value={widthVal}
              onChange={(n) => setDoc((prev) => prev ? ({ ...prev, meta: { ...prev.meta, width: Math.max(0, Math.round(n)) } }) : prev)}
              onCommit={(n) => setDoc((prev) => prev ? ({ ...prev, meta: { ...prev.meta, width: Math.max(0, Math.round(n)) } }) : prev)}
              step={10}
              min={0}
            />
            <MobileStepper
              label="Height"
              value={heightVal}
              onChange={(n) => setDoc((prev) => prev ? ({ ...prev, meta: { ...prev.meta, height: Math.max(0, Math.round(n)) } }) : prev)}
              onCommit={(n) => setDoc((prev) => prev ? ({ ...prev, meta: { ...prev.meta, height: Math.max(0, Math.round(n)) } }) : prev)}
              step={10}
              min={0}
            />
          </div>
        </IOSListGroup>

        <IOSListGroup header="Geometry Settings">
          <IOSListItem
            trailing={
              <Switch
                checked={gf === 1}
                onCheckedChange={(checked) => setDoc((prev) => prev ? ({ ...prev, meta: { ...prev.meta, geometryFlipped: checked ? 1 : 0 } }) : prev)}
              />
            }
          >
            Flipped Geometry
          </IOSListItem>
          <p className="px-4 py-2 text-[13px] text-muted-foreground leading-snug">
            When enabled, origin (0,0) is top-left and Y increases downward. Default is bottom-left and Y increases upward.
          </p>
        </IOSListGroup>
      </div>
    );
  }

  if (!selected) {
    return (
      <div className="h-full flex flex-col items-center justify-center px-6 py-8">
        <div className="flex flex-col items-center text-center">
          <div className="w-16 h-16 rounded-full bg-muted/50 flex items-center justify-center mb-4">
            <SquareSlash className="h-8 w-8 text-muted-foreground" />
          </div>
          <h3 className="text-lg font-semibold mb-1">No Layer Selected</h3>
          <p className="text-sm text-muted-foreground max-w-[260px]">
            Tap a layer in the Layers panel to view and edit its properties.
          </p>
        </div>
      </div>
    );
  }

  const tabProps = {
    selected,
    selectedBase: selectedBase!,
    updateLayer,
    updateLayerTransient,
    getBuf,
    setBuf,
    clearBuf,
    round2,
    fmt2,
    fmt0,
  };

  return (
    <div className="h-full flex flex-col overflow-hidden">
      {/* iOS Segmented Control */}
      <div className="px-4 py-3 shrink-0 overflow-x-auto scrollbar-hide">
        <div className="flex p-1 bg-muted/50 rounded-[12px] w-max min-w-full">
          {tabs.map((tab) => {
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={cn(
                  "flex-1 px-4 py-2.5 min-h-[40px] rounded-[10px] text-sm font-medium transition-all duration-200 ios-active-scale whitespace-nowrap",
                  isActive
                    ? "bg-background shadow-sm text-foreground"
                    : "text-muted-foreground hover:text-foreground"
                )}
              >
                {tab.label}
              </button>
            );
          })}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto">
        {activeTab === 'geometry' && (
          <GeometryTab
            {...tabProps}
            disablePosX={disablePosX}
            disablePosY={disablePosY}
            disablePosZ={disablePosZ}
            disableRotX={disableRotX}
            disableRotY={disableRotY}
            disableRotZ={disableRotZ}
            activeState={current?.activeState}
          />
        )}

        {activeTab === 'compositing' && (
          <CompositingTab {...tabProps} setActiveTab={setActiveTab} activeState={current?.activeState} />
        )}

        {activeTab === 'content' && (
          <ContentTab {...tabProps} setActiveTab={setActiveTab} activeState={current?.activeState} />
        )}

        {activeTab === 'text' && selected.type === "text" && (
          <TextTab {...tabProps} activeState={current?.activeState} />
        )}

        {activeTab === 'gradient' && selected.type === "gradient" && (
          <GradientTab {...tabProps} />
        )}

        {activeTab === 'image' && selected.type === "image" && (
          <ImageTab
            selected={selected}
            updateLayer={updateLayer}
            replaceImageForLayer={replaceImageForLayer}
            activeState={current?.activeState}
          />
        )}

        {activeTab === 'video' && selected.type === "video" && (
          <VideoTab {...tabProps} />
        )}

        {activeTab === 'emitter' && selected.type === "emitter" && (
          <EmitterTab
            {...tabProps}
            addEmitterCellImage={addEmitterCellImage}
          />
        )}

        {activeTab === 'replicator' && selected.type === "replicator" && (
          <ReplicatorTab {...tabProps} />
        )}

        {activeTab === 'animations' && (
          <AnimationsTab {...tabProps} />
        )}

        {activeTab === 'gyro' && (
          <GyroTab
            selected={selected}
            wallpaperParallaxGroups={current?.wallpaperParallaxGroups || []}
            setDoc={setDoc}
          />
        )}
        {activeTab === 'filters' && (
          <FiltersTab {...tabProps} />
        )}
      </div>
    </div>
  );
}
