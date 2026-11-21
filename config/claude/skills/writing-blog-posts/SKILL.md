---
name: writing-blog-posts
description: Write, revise or plan a blog post for Nathan's blog (nathangeerinck.be), or any personal or product story post, and the text to share it on X, LinkedIn or Instagram. Covers the interview, sourcing numbers, structure, attention, voice and publishing. Use when asked to write, draft, rewrite, improve or plan a blog post or article, or what to post along with one.
---

# Writing blog posts

Learned from writing "LaraBug turns 10". The first draft failed because it listed facts in fragmented blocks, sounded generic and was only about the writer. What worked was one continuous essay in Nathan's own voice, built on facts he gave and numbers from real sources, with a reason for a stranger to read it.

## 1. Interview before writing

Never draft from a topic alone. Ask, in one round, short questions the writer can answer in rough notes (any language):

- **The story:** where it started, who was involved, the key dates.
- **The turn:** what stalled or went wrong, and why. What finally changed.
- **The lesson:** one thing they would do again, one they would do differently.
- **The moment:** what launch day or the result felt like, and one reaction that stuck.
- **The reader:** who should finish it feeling it was worth their time.
- **Material:** links, screenshots, videos, an article they admire (read it for style).
- **Off limits:** names, revenue, anything not to mention.

Ask follow ups only where an answer is thin. Do not ask about things the codebase, git history or a public page can answer: look those up.

## 2. Facts only, and say what is interpretation

- Use only what the writer said or what a source shows. Do not invent feelings, quotes, lessons, dates or numbers.
- Where a sentence is your reading of their words, list it after the draft so they can check it ("my interpretation: ...").
- A gap the writer has not filled stays a visible question in the draft, for example `[what changed this year?]`, never a plausible guess.
- Check claims against sources before publishing. Example: the package repository was created on 3 November 2016, while the post said "ten years today" on the 21st. Flag such mismatches instead of silently picking one.

## 3. Find the numbers yourself

Numbers are the strongest proof a post has. Pull them from sources, never estimate:

- **Git history:** `git log --author=... --since=YYYY-01-01 --until=YYYY-12-31 --oneline | wc -l` per year shows effort over time ("113 commits in 2024 and 2025, over 2,000 this year").
- **Releases:** `git tag --sort=creatordate --format='%(creatordate:short) %(refname:short)'` shows gaps and pace ("no release for ten months", "23 betas in seven weeks").
- **Public package stats:** `https://packagist.org/packages/<vendor>/<name>.json` (downloads total and monthly, stars), the GitHub API, `https://api.npmjs.org/downloads/point/last-month/<pkg>`.
- **The product's own announcement** for feature facts, quoted accurately.

Word numbers honestly: Packagist counts downloads (CI included), so write "downloaded", not "used". When two numbers could seem to contradict each other in the text, do not put them side by side.

## 4. Structure

Modelled on Dennis Smink's posts ("Why I started creating Ploi.io", "LaraBug, a Laravel exception tool helper"): short, chronological, honest, concrete.

1. **Opening:** in the first two or three sentences, the claim, who it is for and what they get. Not a warm up.
2. **The story, in order,** with real dates.
3. **Where it stalled, and why,** without dressing it up.
4. **"What I (personally) underestimated":** one lesson, made concrete with a number.
5. **What it is or does:** a short concrete list, then how to try it (one command, one link).
6. **The moment:** launch day or the result, briefly.
7. **Close:** a link to the full details, "That's it. Let me know what you think, and what I can improve." and a thank you where it is owed.

Aim for 500 to 800 words. Write it as one continuous text with a few headings. At most one or two visuals (a real screenshot beats a diagram). Do not chop it into many separate blocks, charts or timelines: that read as fragmented and was rejected.

## 5. Earn the reader's attention

From Eliot's "The Mechanics of Attention":

- **Not only about you.** Before writing, answer: why would a stranger read this, and what do they take away? The personal story carries a lesson for a named group ("If you're building something of your own next to client work...").
- **Deny an assumption.** Advice everyone knows ("ship early") is boring. Put it against what they believe: "Everyone tells you to ship early. I knew that. What I underestimated is how a side project makes it harder." The claim must be true; never be contrarian for its own sake.
- **Go one level deeper into the current conversation.** Connect the story to what people already discuss (for example AI writing code: "Fewer people talk about what happens next").
- **Readable in five seconds.** The title, the excerpt and the first line must say what the post is. Do the work for the reader.
- **Specific numbers over adjectives.**
- **MATT test before publishing:** Memeable (one line people remember, like "there was always one more thing"), Additive, True, Talkable. Fix or cut what fails.

## 6. Voice

- Write like the person talks: plain words, short sentences, contractions, first person, some warmth. A mix of personal and technical.
- Apply the `unslop` skill. No em dashes, no colons as mid sentence connectors, no puffery, no "not just X, but Y", no generic conclusions.
- Do not polish the writer's voice into marketing copy. If they share an article they like, match its tone, not its mistakes.
- Present the full draft in chat so it can be read in one go, followed by the interpretation list and open questions.

## 7. Sharing it

- **X:** lead with the claim or the number, not the title ("In 2024 and 2025 I made 113 commits to LaraBug. This year, more than 2,000."). Upload a visual directly (screenshot or the story video); X shows posts with only an outside link to fewer people. Tag the people the story is about. Offer two or three options; mark which ones only work on a specific day ("today").
- **LinkedIn:** after changing a post that was already shared, refresh its preview with LinkedIn's Post Inspector.
- **Instagram story:** a vertical video in the share image's style, with a calm empty area under a "Read the post" cue for the link sticker, outside Instagram's top and bottom overlay zones.

## 8. On nathangeerinck.be

- Posts are written in the Nodux panel (Content, Posts). The post editor takes pictures inline; screenshots go in the drive's Blog folder.
- Write and check locally first (`http://nathangeerinck.be.test/blog/<slug>`), in light and dark mode.
- Production content lives in the production database. Either the writer pastes it into the panel, or a one time migration writes it (`database/content/<slug>.html`, guarded so it runs once and never overwrites an edit made in the panel).
- Share images are drawn automatically (`og:generate` on deploy). After changing a title, date or excerpt, use "Refresh share image" in the post editor's menu.
- A post only shows when it is Published and its date is not in the future. The server runs on UTC.
