"use client";
// iOS List Group Components

import * as React from "react";
import { cn } from "@/lib/utils";

interface IOSListGroupProps {
    children: React.ReactNode;
    header?: string;
    footer?: string;
    className?: string;
}

export function IOSListGroup({ children, header, footer, className }: IOSListGroupProps) {
    return (
        <div className={cn("flex flex-col gap-1.5 px-4 my-4", className)}>
            {header && (
                <h3 className="px-1 text-[13px] font-semibold text-muted-foreground/80 uppercase tracking-tight">
                    {header}
                </h3>
            )}
            <div className="ios-inset-group mx-0! my-0! divide-y divide-ios-separator">
                {children}
            </div>
            {footer && (
                <p className="px-1 text-[13px] text-muted-foreground/70">
                    {footer}
                </p>
            )}
        </div>
    );
}

interface IOSListItemProps {
    children: React.ReactNode;
    className?: string;
    onClick?: () => void;
    trailing?: React.ReactNode;
}

export function IOSListItem({ children, className, onClick, trailing }: IOSListItemProps) {
    const Component = onClick ? "button" : "div";
    return (
        <Component
            onClick={onClick}
            className={cn(
                "ios-list-item w-full text-left transition-all",
                onClick && "ios-active-scale",
                className
            )}
        >
            <div className="flex-1 text-[17px] font-medium">{children}</div>
            {trailing && <div className="ml-2 text-muted-foreground/50">{trailing}</div>}
        </Component>
    );
}
