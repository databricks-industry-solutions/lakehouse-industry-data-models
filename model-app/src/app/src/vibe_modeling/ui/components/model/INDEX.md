# components/model

Shared model-page chrome. Both the model-version route and the input-review
route render these, so the orchestration around the `ModelView` tab bar lives
in ONE place instead of being duplicated per route.

- `model-tabs-shell.tsx` - `ModelTabsShell`: the full model-page orchestration
  around `ModelView` (business/model/versions fetches, current-version
  resolution, model-element feedback context (diagram selection, the domain the
  Review Progress or Ontology control shows or the picked domain, the
  reviewed input's element via `feedbackSubject`, else the whole model;
  disabled on Artifacts), column-mode preference gate, gated ELK cache warm
  (one domain's layout when the diagram is scoped to a domain, by the input's
  anchor or the picked domain; the all-domains layout otherwise),
  single-home Add-feedback, the version's lifecycle badges in the header
  ("Replaced by v3 on <date>"), and the standard tab bodies).
  `pickedDomain` is the domain picked in the Diagram or Ontology dropdown,
  drawn in place by both tabs; a name that is not a live domain of the model
  counts as all domains. `onOntologyDomainPick` makes the Ontology dropdown
  route-owned (the version page); without it the Ontology filters locally.
  `onOpenDomain` gives the Overview tab its "Go to domain" dropdown.
  Router-owned `?tab=` and `?domain=` (the Diagram and Ontology's shared
  picked domain, kept across tab switches) and the destructive `DeleteVersionButton` stay in the
  route files (the latter injected via `versionActions`).
- `model-overview.tsx` - `ModelOverview` (shared Overview tab body: drift
  reconcile prompt, the producing run's change summary (`VersionChangesSummary`),
  metrics band, domain cards, next-vibes). `showLifecycleActions`
  gates the run/install `CommandStrip` and the compact run report line
  (`VersionReportCompact`); the input-review surface passes `false`.
- `toolbar-note-slot.tsx` - `useToolbarNoteSlot` (the shell's full-width,
  right-aligned line under the tab bar, hidden when empty) and `ToolbarNote`
  (portals a tab-bar action's note there, in place without a provider); the
  version page's Delete reason uses it so it never widens the tab bar.
- `model-search.tsx` - `ModelSearch`: model-wide element search (Cmd/Ctrl-K
  command palette + header trigger) over domains/tables/columns, mounted in the
  shell header (searchTrigger) and wired to per-element-type navigation.
