"use client";

import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Switch } from "@/components/ui/switch";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Slider } from "@/components/ui/slider";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { MobileStepper } from "@/components/ui/mobile-stepper";
import { Fragment, useState } from "react";
import type { InspectorTabProps } from "../types";
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";
import { AlignHorizontalJustifyStart, AlignHorizontalJustifyCenter, AlignHorizontalJustifyEnd, AlignVerticalJustifyStart, AlignVerticalJustifyCenter, AlignVerticalJustifyEnd, Plus, Minus } from "lucide-react";
import { IOSListGroup, IOSListItem } from "@/components/ui/ios-list-group";
import { useLocalStorage } from "@/hooks/use-local-storage";
import { useEditor } from "../../editor-context";
import { getParentAbsContextFor } from "../../canvas-preview/utils/coordinates";

interface GeometryTabProps extends InspectorTabProps {
  disablePosX: boolean;
  disablePosY: boolean;
  disablePosZ: boolean;
  disableRotX: boolean;
  disableRotY: boolean;
  disableRotZ: boolean;
  activeState?: string;
}

export function GeometryTab({
  selected,
  updateLayer,
  updateLayerTransient,
  getBuf,
  setBuf,
  clearBuf,
  round2,
  fmt2,
  fmt0,
  disablePosX,
  disablePosY,
  disablePosZ,
  disableRotX,
  disableRotY,
  disableRotZ,
  activeState,
}: GeometryTabProps) {
  const inState = !!activeState && activeState !== 'Base State';
  const selAx = (selected as any).anchorPoint?.x ?? 0.5;
  const selAy = (selected as any).anchorPoint?.y ?? 0.5;

  const standardValues = [0, 0.5, 1];
  const isStandardAnchor = standardValues.includes(selAx) && standardValues.includes(selAy);

  const [useCustomAnchor, setUseCustomAnchor] = useState(!isStandardAnchor);
  const [resizePercentage, setResizePercentage] = useState(10);
  const [showGeometryResize] = useLocalStorage<boolean>("caplay_settings_show_geometry_resize", false);
  const [showAlignButtons] = useLocalStorage<boolean>("caplay_settings_show_align_buttons", false);
  const [alignTarget, setAlignTarget] = useLocalStorage<'root' | 'parent'>("caplay_settings_align_target", 'parent');
  const { doc } = useEditor();

  const alignLayer = (horizontalAlign?: 'left' | 'center' | 'right', verticalAlign?: 'top' | 'center' | 'bottom') => {
    const key = doc?.activeCA ?? 'floating';
    const current = doc?.docs?.[key];
    if (!current) return;

    const layerWidth = selected.size.w;
    const layerHeight = selected.size.h;

    const parentContext = getParentAbsContextFor(
      selected.id,
      current.layers,
      doc?.meta.height ?? 0,
      doc?.meta.geometryFlipped
    );

    const findParentLayer = (layers: any[], targetId: string, parent: any = null): any => {
      for (const layer of layers) {
        if (layer.id === targetId) return parent;
        if (layer.children) {
          const found = findParentLayer(layer.children, targetId, layer);
          if (found !== null) return found;
        }
      }
      return null;
    };

    const parentLayer = findParentLayer(current.layers, selected.id);
    const targetWidth = (alignTarget === 'root' || !parentLayer) ? (doc?.meta.width ?? 0) : parentLayer.size.w;
    const targetHeight = (alignTarget === 'root' || !parentLayer) ? (doc?.meta.height ?? 0) : parentContext.containerH;

    let targetCssLeft = 0;
    let targetCssTop = 0;

    if (horizontalAlign === 'left') {
      targetCssLeft = 0;
    } else if (horizontalAlign === 'center') {
      targetCssLeft = (targetWidth - layerWidth) / 2;
    } else if (horizontalAlign === 'right') {
      targetCssLeft = targetWidth - layerWidth;
    }

    if (verticalAlign === 'top') {
      targetCssTop = 0;
    } else if (verticalAlign === 'center') {
      targetCssTop = (targetHeight - layerHeight) / 2;
    } else if (verticalAlign === 'bottom') {
      targetCssTop = targetHeight - layerHeight;
    }

    const parentOffsetLeft = alignTarget === 'root' ? parentContext.left : 0;
    const parentOffsetTop = alignTarget === 'root' ? parentContext.top : 0;

    const relativeCssLeft = horizontalAlign ? targetCssLeft - parentOffsetLeft :
      selected.position.x - selAx * layerWidth;
    const relativeCssTop = verticalAlign ? targetCssTop - parentOffsetTop :
      (parentContext.useYUp ?
        (parentContext.containerH - (selected.position.y + (1 - selAy) * layerHeight)) :
        (selected.position.y - selAy * layerHeight));

    const newX = relativeCssLeft + selAx * layerWidth;
    const newY = parentContext.useYUp ?
      ((parentContext.containerH - relativeCssTop) - (1 - selAy) * layerHeight) :
      (relativeCssTop + selAy * layerHeight);

    updateLayer(selected.id, { position: { x: round2(newX), y: round2(newY) } as any });
  };
  return (
    <div className="flex flex-col">
      {(disablePosX || disablePosY || disableRotX || disableRotY || disableRotZ) && (
        <div className="px-4 mb-2">
          <Alert>
            <AlertDescription className="text-xs">
              Position and rotation fields are disabled because this layer has keyframe animations enabled.
            </AlertDescription>
          </Alert>
        </div>
      )}

      <IOSListGroup header="Position">
        <div className="p-3 bg-card space-y-3">
          <MobileStepper
            label="X"
            value={selected.position.x}
            disabled={disablePosX}
            onChange={(v) => updateLayerTransient(selected.id, { position: { ...selected.position, x: v } as any })}
            onCommit={(v) => updateLayer(selected.id, { position: { ...selected.position, x: v } as any })}
            step={1}
          />
          <MobileStepper
            label="Y"
            value={selected.position.y}
            disabled={disablePosY}
            onChange={(v) => updateLayerTransient(selected.id, { position: { ...selected.position, y: v } as any })}
            onCommit={(v) => updateLayer(selected.id, { position: { ...selected.position, y: v } as any })}
            step={1}
          />
          <MobileStepper
            label="Z Position"
            value={selected.zPosition ?? 0}
            disabled={disablePosZ}
            onChange={(v) => updateLayerTransient(selected.id, { zPosition: v })}
            onCommit={(v) => updateLayer(selected.id, { zPosition: v })}
            step={1}
          />
        </div>
      </IOSListGroup>

      {showAlignButtons && (
        <IOSListGroup header="Alignment">
          <div className="p-3 bg-card space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-[17px] font-medium">Align To</span>
              <Select value={alignTarget} onValueChange={(value: 'root' | 'parent') => setAlignTarget(value)}>
                <SelectTrigger className="h-8 w-[110px] bg-secondary-system-background border-none rounded-[8px]">
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="root">Canvas</SelectItem>
                  <SelectItem value="parent">Parent</SelectItem>
                </SelectContent>
              </Select>
            </div>
            <div className="grid grid-cols-6 gap-1">
              <Button type="button" variant="outline" size="sm" onClick={() => alignLayer('left', undefined)} disabled={disablePosX} className="h-10 ios-active-scale"><AlignHorizontalJustifyStart className="h-4 w-4" /></Button>
              <Button type="button" variant="outline" size="sm" onClick={() => alignLayer('center', undefined)} disabled={disablePosX} className="h-10 ios-active-scale"><AlignHorizontalJustifyCenter className="h-4 w-4" /></Button>
              <Button type="button" variant="outline" size="sm" onClick={() => alignLayer('right', undefined)} disabled={disablePosX} className="h-10 ios-active-scale"><AlignHorizontalJustifyEnd className="h-4 w-4" /></Button>
              <Button type="button" variant="outline" size="sm" onClick={() => alignLayer(undefined, 'top')} disabled={disablePosY} className="h-10 ios-active-scale"><AlignVerticalJustifyStart className="h-4 w-4" /></Button>
              <Button type="button" variant="outline" size="sm" onClick={() => alignLayer(undefined, 'center')} disabled={disablePosY} className="h-10 ios-active-scale"><AlignVerticalJustifyCenter className="h-4 w-4" /></Button>
              <Button type="button" variant="outline" size="sm" onClick={() => alignLayer(undefined, 'bottom')} disabled={disablePosY} className="h-10 ios-active-scale"><AlignVerticalJustifyEnd className="h-4 w-4" /></Button>
            </div>
          </div>
        </IOSListGroup>
      )}

      <IOSListGroup header="Size">
        <div className="p-3 bg-card space-y-3">
          <MobileStepper
            label="Width"
            value={selected.size.w}
            disabled={selected.type === 'text' && (((selected as any).wrapped ?? 1) as number) !== 1}
            onChange={(v) => updateLayerTransient(selected.id, { size: { ...selected.size, w: v } as any })}
            onCommit={(v) => updateLayer(selected.id, { size: { ...selected.size, w: v } as any })}
            step={5}
            min={0}
          />
          <MobileStepper
            label="Height"
            value={selected.size.h}
            disabled={selected.type === 'text'}
            onChange={(v) => updateLayerTransient(selected.id, { size: { ...selected.size, h: v } as any })}
            onCommit={(v) => updateLayer(selected.id, { size: { ...selected.size, h: v } as any })}
            step={5}
            min={0}
          />
        </div>
      </IOSListGroup>

      <IOSListGroup header="Rotation (Degrees)">
        <div className="p-3 bg-card space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <MobileStepper
              label="X"
              value={(selected as any).rotationX ?? 0}
              disabled={disableRotX}
              onChange={(v) => updateLayerTransient(selected.id, { rotationX: v as any } as any)}
              onCommit={(v) => updateLayer(selected.id, { rotationX: v as any } as any)}
            />
            <MobileStepper
              label="Y"
              value={(selected as any).rotationY ?? 0}
              disabled={disableRotY}
              onChange={(v) => updateLayerTransient(selected.id, { rotationY: v as any } as any)}
              onCommit={(v) => updateLayer(selected.id, { rotationY: v as any } as any)}
            />
          </div>
          <MobileStepper
            label="Z"
            value={selected.rotation ?? 0}
            disabled={disableRotZ}
            onChange={(v) => updateLayerTransient(selected.id, { rotation: v as any } as any)}
            onCommit={(v) => updateLayer(selected.id, { rotation: v as any } as any)}
          />
        </div>
      </IOSListGroup>

      {selected.type !== 'emitter' && (
        <IOSListGroup header="Anchor Point">
          <div className="p-3 bg-card space-y-3">
            <Tooltip>
              <TooltipTrigger asChild>
                <div className={inState ? 'opacity-50 pointer-events-none' : ''}>
                  {!useCustomAnchor ? (
                    <div className="grid grid-cols-3 gap-1">
                      {([1, 0.5, 0] as number[]).map((ay, rowIdx) => (
                        <Fragment key={`row-${rowIdx}`}>
                          {([0, 0.5, 1] as number[]).map((ax, colIdx) => {
                            const isActive = Math.abs(selAx - ax) < 1e-6 && Math.abs(selAy - ay) < 1e-6;
                            return (
                              <Button key={`ap-${rowIdx}-${colIdx}`} type="button" variant={isActive ? 'default' : 'outline'} size="sm"
                                disabled={inState}
                                className="h-10"
                                onClick={() => updateLayer(selected.id, { anchorPoint: { x: ax, y: ay } as any })}>
                                {ax},{ay}
                              </Button>
                            );
                          })}
                        </Fragment>
                      ))}
                    </div>
                  ) : (
                    <div className="space-y-4">
                      <div className="space-y-2">
                        <Label className="text-xs">X ({Math.round(selAx * 100)}%)</Label>
                        <Slider
                          min={0} max={100} step={1} disabled={inState}
                          value={[Math.round(selAx * 100)]}
                          onValueChange={([v]) => updateLayerTransient(selected.id, { anchorPoint: { x: v / 100, y: selAy } as any })}
                          onValueCommit={([v]) => updateLayer(selected.id, { anchorPoint: { x: v / 100, y: selAy } as any })}
                        />
                      </div>
                      <div className="space-y-2">
                        <Label className="text-xs">Y ({Math.round(selAy * 100)}%)</Label>
                        <Slider
                          min={0} max={100} step={1} disabled={inState}
                          value={[Math.round(selAy * 100)]}
                          onValueChange={([v]) => updateLayerTransient(selected.id, { anchorPoint: { x: selAx, y: v / 100 } as any })}
                          onValueCommit={([v]) => updateLayer(selected.id, { anchorPoint: { x: selAx, y: v / 100 } as any })}
                        />
                      </div>
                    </div>
                  )}
                  <IOSListItem
                    className="mt-2 px-0 py-0 bg-transparent border-none"
                    trailing={<Switch checked={useCustomAnchor} disabled={inState} onCheckedChange={(checked) => {
                      setUseCustomAnchor(checked);
                      if (!checked) {
                        const nearestX = standardValues.reduce((p, c) => Math.abs(c - selAx) < Math.abs(p - selAx) ? c : p);
                        const nearestY = standardValues.reduce((p, c) => Math.abs(c - selAy) < Math.abs(p - selAy) ? c : p);
                        updateLayer(selected.id, { anchorPoint: { x: nearestX, y: nearestY } as any });
                      }
                    }} />}
                  >
                    Custom Anchor
                  </IOSListItem>
                </div>
              </TooltipTrigger>
              {inState && <TooltipContent sideOffset={6}>Not supported for transitions</TooltipContent>}
            </Tooltip>
          </div>
        </IOSListGroup>
      )}

      <IOSListGroup header="Geometry Settings">
        <IOSListItem
          trailing={<Switch checked={(((selected as any).geometryFlipped ?? 0) === 1)} disabled={inState} onCheckedChange={(c) => updateLayer(selected.id, { geometryFlipped: (c ? 1 : 0) as any })} />}
        >
          Flipped Geometry
        </IOSListItem>
      </IOSListGroup>
    </div>
  );
}
