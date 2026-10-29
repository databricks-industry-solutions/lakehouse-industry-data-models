import { screen, waitFor } from "@testing-library/react";

/**
 * Find a section container and wait until its Suspense skeleton is gone.
 *
 * Section wrappers (AreaSection) render immediately and hold a Skeleton until
 * their queries resolve, so `findByTestId(section)` resolves on the skeleton
 * and any synchronous `getBy*` that follows races the data. Negative
 * assertions (`queryBy*` ... not.toBeInTheDocument) would also pass vacuously
 * against the skeleton.
 */
export async function findLoadedByTestId(testId: string): Promise<HTMLElement> {
  const el = await screen.findByTestId(testId);
  await waitFor(() => {
    if (el.querySelector(".animate-pulse")) throw new Error(`${testId} is still loading`);
  });
  return el;
}
