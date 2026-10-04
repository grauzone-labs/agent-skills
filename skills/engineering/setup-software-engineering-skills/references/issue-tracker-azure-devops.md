# Issue tracker: Azure DevOps

Setup reference for generating `docs/agents/issue-tracker.md` for Azure Boards. Run process discovery, settle the applicable workflow mappings, then draft the repository's tracker contract. The operation examples below are templates for that output. Use the Azure CLI with the `azure-devops` extension; use authenticated REST calls when an operation has no supported CLI route.

## Setup and scope

Install the extension and authenticate before the first operation:

```sh
az extension add --name azure-devops
az devops login --organization "https://dev.azure.com/<organization>"
az devops configure --defaults organization="https://dev.azure.com/<organization>" project="<project>"
```

Before drafting `docs/agents/issue-tracker.md`, run the discovery procedure below. Replace command placeholders with the confirmed scope and record the resulting process-specific mappings. Choose completed states from the returned state categories rather than inferring them from names such as `Resolved` or `Done`.

Keep command scope explicit in the generated contract. Pass organization and project to commands that accept them; `az devops invoke` takes project through `--route-parameters` instead of a `--project` option. CLI defaults are optional convenience settings, not the authoritative scope.

## Discover the project's process during setup

### 1. Resolve organization and project

Use the user's explicit organization/project first. Otherwise inspect the Azure Repos remote and existing tracker configuration, then CLI defaults. A Git remote identifies an organization, project, and repository; the repository name is not the project name. Ask for the missing scope or resolve conflicting evidence with the user.

Read the confirmed project's process assignment:

```sh
az devops project show --organization "https://dev.azure.com/<organization>" \
  --project "<project>" \
  --query '{projectId:id,projectName:name,process:capabilities.processTemplate}' -o json
```

Record `templateName` and `templateTypeId`. An inherited process must be inspected by its own ID, not replaced by its parent process's baseline.

### 2. Inspect effective types, fields, rules, and states

List the project's effective work item types and read each applicable type:

```sh
az devops invoke --organization "https://dev.azure.com/<organization>" \
  --area wit --resource workitemtypes --route-parameters project="<project>" \
  --api-version 7.1 -o json

az devops invoke --organization "https://dev.azure.com/<organization>" \
  --area wit --resource workitemtypes \
  --route-parameters project="<project>" type="<type-name>" \
  --api-version 7.1 -o json
```

The type response supplies `fieldInstances`, including `alwaysRequired` and defaults, and `states`, including their categories. Inventory all returned types; distinguish ordinary planning types from review, feedback, shared-test, and test-management types. Generate detailed templates for types used by the configured workflows.

Inspect the assigned process through these REST resources as well:

- `GET /_apis/work/processes/{processId}/workItemTypes?api-version=7.1`
- `GET /_apis/work/processes/{processId}/workItemTypes/{witRefName}/fields?api-version=7.1`
- `GET /_apis/work/processes/{processId}/workItemTypes/{witRefName}/rules?api-version=7.1`
- `GET /_apis/work/processes/{processId}/workItemTypes/{witRefName}/states?api-version=7.1`

Use the Process API's returned `referenceName` for its subsequent calls. It can differ from the project's WIT reference name for an inherited type. Inspect inherited and system rules, including `makeRequired`, defaults, read-only rules, and their conditions. Include disabled-type status and state categories. Confirm backlog hierarchy and the team's Bug behavior when configuring parent relationships.

Read process behaviors and work-item-type behavior associations where exposed, then the intended team's backlog levels and settings. Resolve the intended team with the user when several teams exist. Discover relation metadata with `az boards work-item relation list-type --organization "https://dev.azure.com/<organization>"`. Record Parent and Child reference names and direction. A relation's existence or a type's presence in a backlog does not prove that every proposed type pair is an approved parent-child combination. Mark unsupported custom-type hierarchy claims unverified.

Use `az devops invoke` where its resource routing supports these endpoints. Extension 1.0.8 can reject `--area processes` despite discovering the routes; in that case, use an authenticated REST client or the extension's authenticated SDK client against the same endpoints. Record an access or tooling blocker when field rules cannot be inspected; ask for an authorized export or access before claiming that the generated field contract is complete. Discovery is read-only.

### Failed or incomplete discovery

If authentication is missing or an authenticated query fails, report the failed lookup and explicitly identify unverified types, states, fields, or relationships. Preserve successfully retrieved evidence and its scope. Ask for missing project details or for the user to authenticate and repeat the lookup. Use general templates and repository documents only as proposed conventions, never as proof of current project types, states, or hierarchy.

Before preparing the final draft, either complete verification or obtain the user's explicit agreement to document the remaining gaps as `unverified`. For each accepted gap, record the reason, proposed mapping if supplied, affected operations, and the authenticated lookup needed to resolve it. Leave dependent create, transition, or relation operations blocked. Draft approval permits writing the configuration, not executing those blocked operations. An unavailable endpoint is a verification gap, not evidence that a type or relation is absent.

### 3. Settle workflow mappings

Map feature requests, defects, specifications, and implementation tickets to enabled types whose purpose fits the deliverable. Ask the user which discovered types should represent approved specifications and implementation tickets. A custom type named `Specification` is a candidate, not an automatic selection. If the user requests a type not found by a successful inventory query, ask them to choose an available type or resolve the process configuration. For incomplete discovery, apply the explicit unverified-agreement procedure above.

When `wayfinder` is installed, follow **Choose the map type during setup** under **Wayfinding operations** before drafting the map mapping. When it is absent, preserve those operation conventions and document selection as a prerequisite for first use. Deferred selection does not block setup.

**Complete when** each active workflow has an agreed mapping whose verification status is recorded. Its field/state and relationship contract is verified or its unverified dependencies are explicitly accepted and blocked. The Wayfinder selection is either complete or explicitly deferred because the skill is absent.

### 4. Generate the tracker contract

Write concrete findings into `docs/agents/issue-tracker.md`, rather than copying this discovery recipe as the completed configuration:

- Confirmed organization URL, project name/ID, process name/ID, and inspection date.
- Complete type inventory, with disabled status where exposed, and the types selected for each workflow.
- Agreed workflow-to-type mappings and any deferred Wayfinder selection prerequisite.
- For each selected type, title/content field references, unconditional required fields, defaults, conditional requirements, and whether values are author-supplied or server-managed.
- Initial states and completed-state mappings per type, based on `Completed` categories. Document any other terminal-state policy explicitly. A single `<issue-type>` or `<done-state>` is insufficient when workflows use different types.
- Approved hierarchy, dependency relations, team Bug behavior when relevant, and Test Plans operations for test-management types.
- Triage role-to-tag mappings when `triage` is installed, coordinated with `docs/agents/triage-labels.md`. Treat Azure Boards tags as separate from workflow states; record whether defaults or existing project-specific tags were selected. Reference this authoritative mapping from the labels document instead of maintaining conflicting copies.
- Evidence source, inspection date, and verification status for each mapping or unresolved dependency. Distinguish completed delivery from removal, rejection, and resolution awaiting verification in the completion rules.
- English authoring templates and scoped creation/update examples that supply the required author input and preserve process-managed values.

Use effective project and assigned-process results for every generated field and state mapping, including custom types.

For each selected work item type, group its authoring template under one heading:

- Type name, reference name, purpose, and applicable workflow.
- Required author input, defaulted required fields, and server-managed fields.
- Initial state, completed states, and conditional requirements for supported transitions.
- Exact narrative field references and the Markdown content expected in each. Describe the outcome, scope, constraints, and observable completion conditions. For defects, include expected/actual behavior, impact, reproduction steps, and environment in the fields the type exposes.
- Hierarchy or test-management associations and a creation/update example with the required inputs.

For native Test Plans fields, use their supported structured payloads for steps and parameters and Markdown for accompanying narrative. Select parent relationships from verified hierarchy and team settings rather than assuming the standard Agile hierarchy.

**Complete when** the user has approved the complete contract, including type roles, field requirements, hierarchy, state mappings, triage tags when applicable, and completion rules. Scope/type/state values used in executable examples are confirmed. Explicitly accepted unverified mappings have a reason, recovery lookup, and blocked dependent operations. When `wayfinder` is absent, document deferred selection as a prerequisite rather than generating a map creation command with an unresolved type.

## Markdown storage for multiline text

Always store multiline free-text fields as Markdown source. This applies to Description, Acceptance Criteria, Repro Steps, System Info, custom multiline text fields, and discussion comments. Preserve actual line breaks, Markdown headings, lists, links, and fenced code blocks. Pass the text without converting it to HTML or HTML-escaping it.

During discovery, check the available Markdown support for the selected fields and comment APIs. When a supported API exposes a content-format setting, explicitly select Markdown. Saving Markdown characters alone does not prove that a field is configured for Markdown rendering. Read saved content back to verify the source and, where exposed, its format. If the project or API cannot meet this storage convention, report the blocker before publishing instead of silently converting to HTML.

Native test steps, parameter data, and other structured test-management payloads retain their required structured format. They are not free-text fields; any accompanying narrative uses Markdown.

Include this storage convention in every generated Azure DevOps tracker contract.

## Work item operations for the generated contract

In these examples, `<work-item-type>` means the mapped type for the current deliverable. `<completed-state>` means that type's verified completed state. Substitute known scope, type, and state values during setup; IDs, titles, and content remain inputs supplied when the operation runs.

- **Create**: `az boards work-item create --type "<work-item-type>" --title "..." --description "<Markdown source>"`, plus the mapped type's required author inputs. Follow **Markdown storage for multiline text** for content and format selection. Use `--fields "System.Tags=tag-one;tag-two"` to set tags at creation.
- **Read**: `az boards work-item show --id <id> --expand all` returns fields and relations. Fetch comments with `az devops invoke --area wit --resource comments --route-parameters project="<project>" workItemId=<id> --api-version 7.1-preview -o json`. Follow pagination until all relevant comments are retrieved. Extension 1.0.8 rejects revision-suffixed version strings such as `7.1-preview.4`; use the accepted version form or an authenticated REST client.
- **List issues**: use a WIQL query, selecting `System.Id`, `System.Title`, `System.State`, `System.Tags`, `System.AssignedTo`, and any project-specific fields needed for triage. Example:

  ```sh
  az boards query --wiql "
    SELECT [System.Id], [System.Title], [System.State], [System.Tags], [System.AssignedTo]
    FROM WorkItems
    WHERE [System.TeamProject] = @project
      AND [System.WorkItemType] = '<work-item-type>'
      AND [System.State] <> '<completed-state>'
    ORDER BY [System.ChangedDate] DESC"
  ```

  Generate separate type/state filters when querying several mapped types. Exclude removed or rejected states when the configured queue policy requires it. Filter tags with `[System.Tags] CONTAINS 'tag-name'`.
- **Comment on an issue**: `az boards work-item update --id <id> --discussion "..."`.
- **Apply / remove tags**: update `System.Tags` with `--fields`. Azure DevOps stores tags as a semicolon-separated field, so read the item first, then write the complete intended set: `az boards work-item update --id <id> --fields "System.Tags=tag-a;tag-b"`.
- **Complete**: `az boards work-item update --id <id> --state "<completed-state>" --discussion "..."`. Satisfy the mapped transition's required author inputs and read the item back to verify the saved state.
- **Assign / unassign**: `az boards work-item update --id <id> --assigned-to "<display name or email>"`; clear the field with `--fields "System.AssignedTo="` when the process permits it.

## Implementation operations for the generated contract

Used by the `implement-work-item` skill. During setup, record the Azure Repos repository name, the target branch, and the merge types the target branch's policy allows. Work item IDs and pull request IDs are separate spaces; each operation below names the ID it takes.

- **Blocking dependencies**: `az boards work-item show --id <work-item-id> --expand relations --query "relations[?rel=='System.LinkTypes.Dependency-Reverse'].url" -o tsv` lists the work item's Predecessor links; the number that ends each URL is the blocking work item's ID. `System.LinkTypes.Dependency-Reverse` is the system-defined Predecessor reference name; confirm it against the relation metadata recorded during discovery. The same query with `System.LinkTypes.Hierarchy-Reverse` returns the Parent link.
- **Merged implementation of a dependency**: read the blocker's relations whose `rel` is `ArtifactLink` and whose `attributes.name` is `Pull Request`; each artifact URL ends in a pull request ID. Then run `az repos pr show --id <pr-id> --query '{status:status,target:targetRefName,merge:lastMergeCommit.commitId}'`. The implementation is merged when `status` is `completed` and `target` is the target branch. A blocker in a completed state without such a pull request is unverified.
- **Commit references**: `#<work-item-id>` in a commit message links the commit to the work item when commit mention linking is enabled for the repository.
- **List open pull requests**: `az repos pr list --repository "<repository>" --target-branch "<target-branch>" --status active`.
- **Open a pull request**: `az repos pr create --repository "<repository>" --source-branch "<work-branch>" --target-branch "<target-branch>" --title "..." --description "<Markdown source>" --work-items <work-item-id>`. `--work-items` creates the closing link. Leave `--auto-complete` unset; the user's go completes the pull request. The description holds up to 4000 characters.
- **Read checks and reviews**: `az repos pr policy list --id <pr-id>` returns each branch policy evaluation with its `status` and whether its configuration is blocking. `az repos pr reviewer list --id <pr-id>` returns the votes: `10` approved, `5` approved with suggestions, `0` no vote, `-5` waiting for author, `-10` rejected. Read review comments through the Pull Request Threads REST resource.
- **Read the conflict state**: `az repos pr show --id <pr-id> --query mergeStatus -o tsv`. `succeeded` means the pull request can merge, `conflicts` means the work branch needs a sync, and `queued` means the evaluation is still running; read it again.
- **Complete with a rebase merge**: `az repos pr update` in extension 1.0.8 offers only the default no-fast-forward merge and `--squash`. Select the rebase strategy through the Pull Requests Update REST resource:

  ```sh
  head=$(az repos pr show --id <pr-id> --query lastMergeSourceCommit.commitId -o tsv)
  cat > pr-complete.json <<EOF
  {
    "status": "completed",
    "lastMergeSourceCommit": { "commitId": "$head" },
    "completionOptions": {
      "mergeStrategy": "rebase",
      "deleteSourceBranch": true,
      "transitionWorkItems": true
    }
  }
  EOF
  az devops invoke --organization "https://dev.azure.com/<organization>" \
    --area git --resource pullRequests \
    --route-parameters project="<project>" repositoryId="<repository>" pullRequestId=<pr-id> \
    --http-method PATCH --in-file pr-complete.json --api-version 7.1 -o json
  ```

  `rebase` is the strategy the web UI calls "Rebase and fast-forward". Confirm that `$head` is the reviewed head commit before sending. Completion runs asynchronously: read `az repos pr show --id <pr-id>` again until `status` is `completed`. A `mergeStatus` of `rejectedByPolicy` means a branch policy blocks the completion, for example one that excludes the rebase merge type; report it.
- **Confirm the result**: `git ls-remote --heads origin "<work-branch>"` returns nothing once the source branch is deleted. `transitionWorkItems` moves each linked work item to its next logical state, which can differ from the completed state. Read the work item and apply **Complete** from the work item operations when it has not reached its completed state.

The commands above are checked against the help of extension 1.0.8 and the REST 7.1 reference. Record in the generated contract which of them were exercised against the project.

## Pull requests as a triage surface

**PRs as a request surface: no.** _(Set to `yes` if this repo treats external PRs as feature requests; the `triage` skill reads this flag.)_

When set to `yes`, record PR-specific triage operations. Work item types, states, and `System.Tags` do not apply to PRs. Use linked work items for triage roles when that is the agreed policy.

- **Read a PR**: `az repos pr show --id <id>`. There is no `az repos pr diff` command. Inspect changes through the Git Pull Request Iterations/Changes REST resources or fetch the returned source and target refs and compare them with Git. Inspect the actual PR change set, not unrelated local changes.
- **List PRs for triage**: `az repos pr list --status active --repository "<repository>"`. Azure DevOps does not expose GitHub's `authorAssociation` equivalent in this command; determine whether an author is external through the project's identity/member data before treating a PR as an external request.
- **Comment / close**: use the Azure DevOps Git Pull Request Threads REST API through `az devops invoke` to add or read thread comments. Close/abandon with `az repos pr update --id <id> --status abandoned`.

Work-item IDs and pull-request IDs are separate spaces. A bare `#42` is ambiguous: determine from context whether it is a work item or PR, then use `az boards work-item show --id 42` or `az repos pr show --id 42`.

## When a skill says "publish to the issue tracker"

Create an Azure Boards work item using the verified type mapping for the requested deliverable. A specification, defect, implementation task, and Wayfinder map can require different types and fields. If a required type, state, or relationship is unverified, resolve its recorded lookup before publishing or changing hierarchy.

## When a skill says "fetch the relevant ticket"

Run `az boards work-item show --id <id> --expand all`, then fetch its comments through the Work Item Comments REST resource when the discussion is relevant.

## Wayfinding operations

Used by the `wayfinder` skill. The **map** is one Azure Boards work item with child work items as tickets.

### Choose the map type during setup

Run this selection only when exploration confirmed that `wayfinder` is installed. If absent, record a first-use prerequisite to ask this question and verify the selected types before creating a map. Preserve the operation conventions in prose and defer type-specific commands.

After process discovery, present the enabled planning work item types returned for the project. Recommend a type whose role and hierarchy fit a decision map, explain that recommendation briefly, and ask:

> Which of these work item types should represent the Wayfinder map: <discovered planning type names>?

Wait for the user's selection before generating type-specific commands. Include a custom `Wayfinder` type when discovered, but let the user choose it explicitly. Offer planning types suitable for a map; test-management and tooling-managed review or feedback types are not map candidates.

Record the selected type and its reference name, required author inputs, initial state, and completed state in `docs/agents/issue-tracker.md`. Use that mapping for the map creation command. Determine the child-ticket type separately and confirm it with the user when its purpose or permitted hierarchy is uncertain.

**Complete when** the user has selected the map and decision-ticket type mappings, and their field/state contracts and intended child relationships are verified. If the user explicitly accepts an unverified draft, record those gaps and keep map/ticket creation blocked until they are resolved.

### Generate the operations

- **Map**: create a work item tagged `wayfinder:map`. Use the canonical map body from the `wayfinder` skill as its description:

  ```sh
  az boards work-item create --type "<selected-map-type>" --title "..." \
    --description "<canonical Wayfinder map body>" \
    --fields "System.Tags=wayfinder:map"
  ```

- **Child ticket**: create the mapped child work item type with the tag `wayfinder:<decision-kind>`, where decision kind is `research`, `prototype`, `grilling`, or `task`. The tag suffix is not a work item type. Put `Wayfinding order: <NN>` at the top of its description, assigning consecutive order numbers in breadth-first discovery order. Then create a parent relation from the child to the map:

  ```sh
  az boards work-item relation add --id <child-id> --relation-type parent --target-id <map-id>
  ```

  If hierarchy links are unavailable in the selected process, put `Part of #<map-id>` above `Wayfinding order: <NN>` at the top of the child description. Query those markers to find the map's tickets. Once claimed, assign the ticket to the driving developer.
- **Blocking**: use the process's native predecessor/dependency relation rather than a text-only convention. First discover the relation name the organization exposes with `az boards work-item relation list-type`, then add the relation to represent “child is blocked by blocker”. Confirm its direction from the returned relation metadata before writing it. If dependency links are unavailable, put `Blocked by: #<id>, #<id>` at the top of the child description. A ticket is unblocked only when every blocker is in its configured done state.
- **Frontier query**: query the map's open children by parent relation (or the fallback `Part of #<map-id>` text), then drop tickets that have an open dependency/predecessor or a non-empty `System.AssignedTo`. Sort the remainder by `Wayfinding order` ascending; the lowest number wins.
- **Claim**: `az boards work-item update --id <id> --assigned-to "<current developer>"` - the session's first write.
- **Resolve**: `az boards work-item update --id <id> --discussion "<answer>" --state "<completed-state>"`, using the child type's state and required transition inputs. Then append the answer's artifact and link to the map's Decisions so far.

When generating commands, use the selected map type and independently mapped child type, including their required author inputs and completed states. Check assignment defaults: a process can assign the creator automatically. Establish unclaimed tickets by clearing assignment when allowed, or agree on another claim marker and adapt the frontier filter before using it.
