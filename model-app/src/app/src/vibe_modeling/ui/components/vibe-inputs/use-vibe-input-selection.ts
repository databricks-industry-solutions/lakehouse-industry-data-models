import { useIsMutating, useQueryClient, type Query } from "@tanstack/react-query";
import { useSetVibeInputSelection, listVibeInputsKey, type VibeInputOut } from "@/lib/api";
import { invalidateVibeInputQueries } from "./query-keys";

export const SELECTION_SAVING_MESSAGE = "Saving your selection… try again in a moment";

type InputsList = { data: VibeInputOut[] };

const LIST_HEAD = listVibeInputsKey()[0];

/**
 * The one writer of `selected_for_run`. The server keeps the last request it
 * receives, and the run compiles what the server holds, so requests must reach
 * it in click order. A shared `mutationKey` does not order anything; a
 * mutation `scope` does: mutations with the same scope id run one at a time, in
 * the order they were fired, across every component under the QueryClient.
 * The optimistic update runs when the mutation is fired (before it waits for
 * its turn), so the screen follows the clicks while the requests drain.
 */
export function vibeInputSelectionScope(businessId: string) {
  return { id: `vibe-input-selection-${businessId}` };
}

export function vibeInputSelectionMutationKey(businessId: string) {
  return ["set-vibe-input-selection", businessId] as const;
}

/**
 * True from the first queued selection write until the list has been refetched
 * after the last one, so a screen that reads or sends the selection (Start run,
 * the run form's Launch) can wait for the settled list.
 */
export function useIsSelectionSaving(businessId: string): boolean {
  return useIsMutating({ mutationKey: vibeInputSelectionMutationKey(businessId) }) > 0;
}

export function useVibeInputSelection(businessId: string) {
  const queryClient = useQueryClient();
  const mutationKey = vibeInputSelectionMutationKey(businessId);

  const isBusinessInputsList = (q: Query) => {
    const [head, params] = q.queryKey as [unknown, { business_id?: string } | undefined];
    return head === LIST_HEAD && params?.business_id === businessId;
  };

  return useSetVibeInputSelection({
    mutation: {
      mutationKey,
      scope: vibeInputSelectionScope(businessId),
      onMutate: async ({ data }) => {
        await queryClient.cancelQueries({ predicate: isBusinessInputsList });
        const ids = new Set(data.input_ids);
        queryClient.setQueriesData<InputsList>({ predicate: isBusinessInputsList }, (curr) =>
          curr
            ? {
                data: curr.data.map((i) =>
                  ids.has(i.id) ? { ...i, selected_for_run: data.selected } : i,
                ),
              }
            : curr,
        );
      },
      // Reconcile with the server once the queue is empty. A refetch while
      // later requests are still waiting would overwrite their optimistic
      // state with a snapshot taken before they ran. The settling mutation
      // still counts as pending here, hence <= 1. Returning the refetch keeps
      // the mutation pending until the settled list is in the cache.
      onSettled: () =>
        queryClient.isMutating({ mutationKey }) <= 1
          ? invalidateVibeInputQueries(queryClient, businessId)
          : undefined,
    },
  });
}
