package skillboard

import "context"

// How to use Processor interface
// Call Scopes to get a slice of scopes that the Processor supports
// Loops over that slice, if the user use one of more of the scopes
// that the processor supports, call the Process func passing in the
// User. That process func will evaluate the user's scopes to determine
// which internal functionality to call

type Processor interface {
	Process(ctx context.Context, user *User) error
}

type ScopeProcessors []Processor

type Scope string

const (
	ReadImplantsV1   Scope = "esi-clones.read_implants.v1"
	ReadSkillQueueV1 Scope = "esi-skills.read_skillqueue.v1"
	ReadSkillsV1     Scope = "esi-skills.read_skills.v1"
)

var AllScopes = []Scope{
	ReadImplantsV1,
	ReadSkillQueueV1,
	ReadSkillsV1,
}

func (s Scope) String() string {
	return string(s)
}

type UserScopes []Scope
