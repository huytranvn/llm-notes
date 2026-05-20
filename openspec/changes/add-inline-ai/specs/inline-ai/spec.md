## ADDED Requirements

### Requirement: Selection-triggered actions
The editor SHALL expose AI actions on the current text selection via a contextual menu, the Edit menu, and the `⌘⇧A` keyboard shortcut.

#### Scenario: Trigger via shortcut
- **WHEN** the user has a non-empty selection and presses `⌘⇧A`
- **THEN** the inline AI action picker SHALL appear adjacent to the selection

#### Scenario: Trigger via context menu
- **WHEN** the user right-clicks a non-empty selection
- **THEN** an "AI Actions" submenu SHALL list configured actions

#### Scenario: No selection
- **WHEN** the user invokes an action with no selection
- **THEN** the picker SHALL be disabled
- **AND** the menu items SHALL be greyed out

### Requirement: Built-in and custom prompts
The system SHALL ship with built-in actions (Rewrite, Summarize, Continue, Translate, Explain) and SHALL allow the user to define additional `PromptTemplate` entries in Settings.

#### Scenario: Built-in action exists on first launch
- **WHEN** the user opens the inline AI picker on a fresh install
- **THEN** Rewrite, Summarize, Continue, Translate, and Explain SHALL be listed

#### Scenario: Add a custom prompt
- **WHEN** the user adds a `PromptTemplate` in Settings with name, system prompt, and user-prompt template
- **THEN** it SHALL appear in the picker
- **AND** SHALL persist across restarts

### Requirement: Ghost-overlay accept / reject
While the AI is generating, output SHALL stream into a non-destructive ghost overlay rendered over the selection. The original text SHALL not be modified until the user accepts.

#### Scenario: Accept
- **WHEN** the user presses `↵` while the ghost overlay is visible
- **THEN** the selection SHALL be replaced with the streamed output
- **AND** the change SHALL be a single undo step

#### Scenario: Reject
- **WHEN** the user presses `⎋` while the ghost overlay is visible
- **THEN** the overlay SHALL be discarded
- **AND** the buffer SHALL be unchanged

#### Scenario: Streaming continues during preview
- **WHEN** the AI is still streaming
- **THEN** the overlay SHALL update in place as deltas arrive

### Requirement: Cancellation
Inline AI requests SHALL be cancellable; navigating away or pressing `⎋` SHALL terminate the in-flight `Task` and close the underlying URLSession connection.

#### Scenario: User navigates away mid-stream
- **WHEN** the user clicks into another note while inline AI is streaming
- **THEN** the streaming task SHALL be cancelled
- **AND** the ghost overlay SHALL be removed

### Requirement: Uses the configured default provider
Inline AI SHALL use the user's selected default provider and model from Settings; the selection action UI SHALL allow overriding the model for a single run.

#### Scenario: Default model
- **WHEN** the user runs an inline action without overriding
- **THEN** the request SHALL use the default provider/model from `ProviderConfigStore`

#### Scenario: One-shot override
- **WHEN** the user picks a different model from the action picker
- **THEN** that model SHALL be used for that single run only
- **AND** the default SHALL not be changed
