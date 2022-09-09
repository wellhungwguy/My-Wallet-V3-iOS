# Sometimes it's a README fix, or something like that - which isn't relevant for
# including in a project's CHANGELOG for example

# Make it more obvious that a PR is a work in progress and shouldn't be merged yet
warn("PR is classed as Work in Progress") if github.pr_labels == "In Progress"

failure("PR is classed as not ready to be merged") if github.pr_labels == "Don't Merge Yet"

declared_trivial = github.pr_labels == "Easy PR"

swiftlint.lint_files
swiftlint.lint_files inline_mode: true
swiftlint.lint_all_files = false

ios_ticket_referenced = github.pr_title.include? "IOS-"

if !ios_ticket_referenced
	warn "All PRs should include a JIRA ticket in the title."
end

failure "Please add labels to this PR" if github.pr_labels.empty?

# Warn when there is a big PR
warn("Big PR") if git.lines_of_code > 1300
