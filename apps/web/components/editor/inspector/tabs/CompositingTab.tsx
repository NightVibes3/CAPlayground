"use client";

import { Input } from "@/components/ui/input";
import { Slider } from "@/components/ui/slider";
import { Label } from "@/components/ui/label";
import { Switch } from "@/components/ui/switch";
import { MobileStepper } from "@/components/ui/mobile-stepper";
import type { InspectorTabProps, TabId } from "../types";
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { blendModes } from "@/lib/blending";
import { IOSListGroup, IOSListItem } from "@/components/ui/ios-list-group";

interface CompositingTabProps extends InspectorTabProps {
  setActiveTab: (tab: TabId) => void;
  activeState?: string;
}

export function CompositingTab({
  selected,
  updateLayer,
  updateLayerTransient,
  getBuf,
  setBuf,
  clearBuf,
  fmt0,
  setActiveTab,
  activeState,
}: CompositingTabProps) {
  const inState = !!activeState && activeState !== 'Base State';
  return (
    <div className="flex flex-col">
      <IOSListGroup header="Blending">
        <div className="p-3 bg-card">
          <Select
            value={selected.blendMode}
            onValueChange={(v) => updateLayer(selected.id, { blendMode: v as any } as any)}
          >
            <SelectTrigger className="w-full bg-secondary-system-background border-none rounded-[10px] h-11">
              <SelectValue placeholder="Select blending mode" />
            </SelectTrigger>
            <SelectContent>
              {Object.values(blendModes).map((mode) => (
                <SelectItem key={mode.id} value={mode.id}>
                  {mode.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        </div>
      </IOSListGroup>

      <IOSListGroup header="Opacity">
        <div className="p-3 bg-card space-y-3">
          <div className="flex items-center gap-4">
            <Slider
              className="flex-1"
              value={[Math.round((typeof selected.opacity === 'number' ? selected.opacity : 1) * 100)]}
              min={0}
              max={100}
              step={1}
              onValueChange={([p]) => {
                const clamped = Math.max(0, Math.min(100, Math.round(Number(p))));
                const val = Math.round((clamped / 100) * 100) / 100;
                updateLayerTransient(selected.id, { opacity: val as any } as any);
              }}
            />
            <div className="w-16 h-11 bg-secondary-system-background rounded-[10px] flex items-center justify-center">
              <input
                className="w-full bg-transparent text-center focus:outline-none text-[17px] font-medium"
                type="number"
                value={getBuf('opacityPct', String(Math.round((typeof selected.opacity === 'number' ? selected.opacity : 1) * 100)))}
                title="Opacity percentage"
                aria-label="Opacity percentage"
                onChange={(e) => {
                  setBuf('opacityPct', e.target.value);
                  const v = e.target.value.trim();
                  if (v === "") return;
                  const val = Math.max(0, Math.min(100, Math.round(Number(v)))) / 100;
                  updateLayerTransient(selected.id, { opacity: val as any } as any);
                }}
                onBlur={(e) => {
                  const v = e.target.value.trim();
                  const val = v === "" ? undefined : Math.max(0, Math.min(100, Math.round(Number(v)))) / 100;
                  updateLayer(selected.id, { opacity: val as any });
                  clearBuf('opacityPct');
                }}
              />
            </div>
          </div>
          <p className="text-[12px] text-muted-foreground leading-tight px-1">
            Opacity affects the entire layer. For background only, use{' '}
            <button
              type="button"
              className="text-ios-blue hover:underline"
              onClick={() => setActiveTab('content')}
            >
              Content → Background
            </button>.
          </p>
        </div>
      </IOSListGroup>

      <IOSListGroup header="Shape">
        <div className="p-3 bg-card">
          <MobileStepper
            label="Corner Radius"
            value={(selected as any).cornerRadius ?? (selected as any).radius ?? 0}
            onChange={(v) => updateLayerTransient(selected.id, { cornerRadius: v as any } as any)}
            onCommit={(v) => updateLayer(selected.id, { cornerRadius: v as any } as any)}
            step={1}
            min={0}
          />
        </div>
      </IOSListGroup>

      <IOSListGroup header="Rendering">
        <IOSListItem
          trailing={
            <Tooltip>
              <TooltipTrigger asChild>
                <div>
                  <Switch
                    checked={(((selected as any).masksToBounds ?? 0) === 1)}
                    disabled={inState}
                    onCheckedChange={(checked) =>
                      updateLayer(selected.id, { masksToBounds: (checked ? 1 : 0) as any } as any)
                    }
                  />
                </div>
              </TooltipTrigger>
              {inState && (
                <TooltipContent sideOffset={6}>Not supported for transitions</TooltipContent>
              )}
            </Tooltip>
          }
        >
          Clip contents
        </IOSListItem>
      </IOSListGroup>
    </div>
  );
}
