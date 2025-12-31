import { useEffect, useRef } from "react";
import { useTimeline } from "@/context/TimelineContext";
import { VideoLayer } from "@/lib/ca/types";
import useStateTransition from "@/hooks/use-state-transition";
import { assetCache, useVideoFrames } from "@/hooks/use-asset-url";

interface VideoRendererProps {
  layer: VideoLayer;
}

function SyncChild({ child, video, index }: { child: any; video: VideoLayer; index: number }) {
  const transition = useStateTransition(child);
  const frameAssetId = `${video.id}_frame_${index}`;
  const imageSrc = assetCache.get(frameAssetId);
  const imgRef = useRef<HTMLImageElement>(null);

  useEffect(() => {
    if (imgRef.current) {
      imgRef.current.style.zIndex = String(transition.zPosition ?? 0);
      imgRef.current.style.borderRadius = `${video.cornerRadius}px`;
    }
  }, [transition.zPosition, video.cornerRadius]);

  if (!imageSrc) return null;

  return (
    <img
      ref={imgRef}
      src={imageSrc}
      alt={child.name}
      className="renderer-video-sync-child"
      draggable={false}
    />
  );
}

function SyncWithStateRenderer({
  video,
}: {
  video: VideoLayer;
}) {
  if (!video.children || video.children.length === 0) return null;

  return (
    <div className="relative w-full h-full">
      {video.children.map((child, index) => (
        <SyncChild
          key={child.id}
          child={child}
          video={video}
          index={index}
        />
      ))}
    </div>
  );
}

export default function VideoRenderer({
  layer: video,
}: VideoRendererProps) {
  // ALL HOOKS MUST BE AT THE TOP - BEFORE ANY CONDITIONAL RETURNS
  const { currentTime } = useTimeline();
  const mainImgRef = useRef<HTMLImageElement>(null);
  
  const frameCount = video.frameCount || 0;
  const fps = video.fps || 30;
  const duration = video.duration || (frameCount / fps);
  const autoReverses = video.autoReverses || false;

  const { frames, loading } = useVideoFrames({
    videoId: video.id,
    frameCount,
    framePrefix: video.framePrefix || "",
    frameExtension: video.frameExtension || "",
    skip: frameCount <= 1,
  });

  useEffect(() => {
    if (mainImgRef.current) {
      mainImgRef.current.style.borderRadius = `${video.cornerRadius}px`;
    }
  }, [video.cornerRadius]);

  // NOW safe to do conditional returns
  if (frameCount <= 1) return null;

  if (video.syncWWithState) {
    return <SyncWithStateRenderer video={video} />;
  }

  let localT = (currentTime / 1000) % duration;
  if (autoReverses) {
    const cycle = duration * 2;
    const m = (currentTime / 1000) % cycle;
    localT = m <= duration ? m : (cycle - m);
  }

  const frameIndex = Math.floor(localT * fps) % frameCount;
  const src = frames.get(frameIndex);

  if (loading || !src) return null;
  
  return (
    <img
      ref={mainImgRef}
      src={src}
      alt={video.name}
      className="w-full h-full object-cover renderer-video-img"
      draggable={false}
    />
  );
}
