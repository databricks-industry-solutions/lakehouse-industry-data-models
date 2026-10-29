import type { BusyAutoRetry } from "@/lib/taxonomy/busy-retry";
import { RetryCountdown } from "@/components/feature-gate";

export const BUSY_LEAD = "The model is busy.";
export const BUSY_EXHAUSTED_COPY = "Still busy. Retry, or Cancel and come back later.";

type Props = {
  state: BusyAutoRetry;
  /** Label for the retry button where the step already names it ("Retry domains"). */
  retryLabel?: string;
  testId?: string;
};

/** What a busy draft part shows: the shared retry line with its countdown, Retry now and Cancel;
 *  once the automatic attempts are used up, manual Retry and Cancel only. */
export function BusyCountdown({ state, retryLabel, testId = "busy-countdown" }: Props) {
  return (
    <RetryCountdown
      lead={BUSY_LEAD}
      state={state}
      exhaustedText={BUSY_EXHAUSTED_COPY}
      retryLabel={retryLabel}
      cancelable
      testId={testId}
    />
  );
}
