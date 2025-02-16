import { useState, useEffect } from "react";

export function useDebounce(value: string, delay_ms: number) {
    const [debouncedValue, setDebouncedValue] = useState(value);

    useEffect(() => {
        const handler = setTimeout(() => {
            setDebouncedValue(value);
        }, delay_ms);
        return () => clearTimeout(handler);
    }, [value, delay_ms]);

    return debouncedValue;
}
