Add a new field to an existing model and all related files: $ARGUMENTS

Format: "fieldName: type to ModelName [optional notes]"
Example: /project:add-field "loyaltyPoints: Number to User, default 0, min 0"
Example: /project:add-field "isVerified: Boolean to Product, admin-only write"

Use the `db-schema-designer` agent from `.claude/agents/db-schema-designer.md`.

Steps to follow:
1. Read the existing model in `backend/models/<Model>.js`
2. Add the field with correct type, constraints, and default
3. Check if any existing controllers need updating to include this field in responses or allow it in writes
4. Check if the Flutter model class (`gold/lib/features/.../models/`) needs `fromJson`/`toJson` updated
5. Check if any Zod validation schemas need updating to allow/require the new field

For each file changed, show the exact diff.

After all changes, answer:
- Do existing documents in MongoDB need a migration? (yes if `required: true` with no `default`)
- Is this field safe to expose to the client, or should it be excluded with `.select()`?
