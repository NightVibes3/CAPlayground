import { useRef, RefObject } from 'react';
import type { TouchEvent, WheelEvent } from 'react';

interface UseTouchGesturesProps {
  canvasRef: RefObject<HTMLDivElement | null>;
  baseOffsetX: number;
  baseOffsetY: number;
  fitScale: number;
  pan: { x: number; y: number };
  scale: number;
  userScale: number;
  setUserScale: (scale: number) => void;
  setPan: (pan: { x: number; y: number }) => void;
  pinchZoomSensitivity: number;
}

export function useTouchGestures({
  canvasRef,
  baseOffsetX,
  baseOffsetY,
  fitScale,
  pan,
  scale,
  userScale,
  setUserScale,
  setPan,
  pinchZoomSensitivity,
}: UseTouchGesturesProps) {

  const touchGestureRef = useRef<{
    startUserScale: number;
    startPanX: number;
    startPanY: number;
    startDist: number;
    startCenterX: number;
    startCenterY: number;
    startTouchX: number;
    startTouchY: number;
    isPinching: boolean;
  } | null>(null);

  const handleWheel = (e: WheelEvent<HTMLDivElement>) => {
    // Wheel-based zoom/pan is disabled per user request
    if (e.ctrlKey || e.shiftKey) {
      e.preventDefault();
    }
  };

  const handleTouchStart = (e: TouchEvent<HTMLDivElement>) => {
    if (!canvasRef.current) return;

    // Ignore touches on Moveable controls or layers themselves
    const target = e.target as HTMLElement;
    if (
      target.closest('.moveable-control') ||
      target.closest('.moveable-line') ||
      target.closest('.moveable-area') ||
      target.closest('[data-layer-id]')
    ) {
      return;
    }

    const rect = canvasRef.current.getBoundingClientRect();

    if (e.touches.length === 1) {
      // Single finger for panning
      const t = e.touches[0];
      touchGestureRef.current = {
        startUserScale: userScale,
        startPanX: pan.x,
        startPanY: pan.y,
        startDist: 0,
        startCenterX: 0,
        startCenterY: 0,
        startTouchX: t.clientX - rect.left,
        startTouchY: t.clientY - rect.top,
        isPinching: false,
      };
    } else if (e.touches.length >= 2) {
      // Two fingers for pinch-zoom
      e.preventDefault();
      const [t1, t2] = [e.touches[0], e.touches[1]];
      const cx = (t1.clientX + t2.clientX) / 2 - rect.left;
      const cy = (t1.clientY + t2.clientY) / 2 - rect.top;
      const dx = t2.clientX - t1.clientX;
      const dy = t2.clientY - t1.clientY;
      const dist = Math.hypot(dx, dy);
      touchGestureRef.current = {
        startUserScale: userScale,
        startPanX: pan.x,
        startPanY: pan.y,
        startDist: dist,
        startCenterX: cx,
        startCenterY: cy,
        startTouchX: 0,
        startTouchY: 0,
        isPinching: true,
      };
    }
  };

  const handleTouchMove = (e: TouchEvent<HTMLDivElement>) => {
    // Touch panning and pinch-zoom are disabled per user request
    if (e.touches.length === 1 || e.touches.length >= 2) {
      e.preventDefault();
    }
  };

  const handleTouchEnd = () => {
    touchGestureRef.current = null;
  };

  const handleTouchCancel = () => {
    touchGestureRef.current = null;
  };

  return {
    handleWheel,
    handleTouchStart,
    handleTouchMove,
    handleTouchEnd,
    handleTouchCancel,
  };
}
