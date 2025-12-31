"use client";

import * as React from "react";
import { Plus, Minus } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { cn } from "@/lib/utils";

interface MobileStepperProps {
    value: number;
    onChange: (value: number) => void;
    onCommit?: (value: number) => void;
    min?: number;
    max?: number;
    step?: number;
    label?: string;
    className?: string;
    disabled?: boolean;
}

export function MobileStepper({
    value,
    onChange,
    onCommit,
    min,
    max,
    step = 1,
    label,
    className,
    disabled = false,
}: MobileStepperProps) {
    const [localValue, setLocalValue] = React.useState(value.toString());

    React.useEffect(() => {
        setLocalValue(value.toString());
    }, [value]);

    const handleIncrement = () => {
        const newValue = Math.min(max ?? Infinity, value + step);
        onChange(newValue);
        onCommit?.(newValue);
    };

    const handleDecrement = () => {
        const newValue = Math.max(min ?? -Infinity, value - step);
        onChange(newValue);
        onCommit?.(newValue);
    };

    const handleBlur = () => {
        const num = parseFloat(localValue);
        if (!isNaN(num)) {
            const clamped = Math.max(min ?? -Infinity, Math.min(max ?? Infinity, num));
            onChange(clamped);
            onCommit?.(clamped);
        } else {
            setLocalValue(value.toString());
        }
    };

    return (
        <div className={cn("flex flex-col gap-1.5", className)}>
            {label && <label className="text-[11px] font-semibold text-muted-foreground/80 uppercase tracking-tight ml-1">{label}</label>}
            <div className="flex items-center bg-secondary-system-background rounded-[10px] overflow-hidden">
                <button
                    className="h-11 w-10 shrink-0 flex items-center justify-center transition-all ios-active-scale disabled:opacity-30"
                    onClick={handleDecrement}
                    disabled={disabled || (min !== undefined && value <= min)}
                    aria-label="Decrement"
                >
                    <Minus className="h-4 w-4 text-ios-blue" />
                </button>
                <input
                    type="number"
                    value={localValue}
                    onChange={(e) => setLocalValue(e.target.value)}
                    onBlur={handleBlur}
                    disabled={disabled}
                    className="h-11 flex-1 min-w-0 bg-transparent text-center focus:outline-none text-[17px] font-medium px-1"
                    aria-label={label || "Value"}
                    title={label || "Value"}
                />
                <button
                    className="h-11 w-10 shrink-0 flex items-center justify-center transition-all ios-active-scale disabled:opacity-30"
                    onClick={handleIncrement}
                    disabled={disabled || (max !== undefined && value >= max)}
                    aria-label="Increment"
                    title="Increment"
                >
                    <Plus className="h-4 w-4 text-ios-blue" />
                </button>
            </div>
        </div>
    );
}
