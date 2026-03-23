#!/usr/bin/env python3
import os
import re
import json

def parse_hypr_config(file_path, variables=None, current_category="General"):
    if variables is None:
        variables = {}
    
    expanded_path = os.path.expanduser(file_path)
    if not os.path.isabs(expanded_path):
        expanded_path = os.path.join(os.path.expanduser("~/.config/hypr"), expanded_path)

    if not os.path.exists(expanded_path):
        return [], variables

    binds = []
    try:
        with open(expanded_path, 'r') as f:
            lines = f.readlines()
    except Exception:
        return [], variables

    for line in lines:
        raw_line = line.strip()
        if not raw_line or (raw_line.startswith("#") and not re.match(r'^#+\s*[A-Z]', raw_line)):
            continue

        # Variables: $name = value
        var_match = re.match(r'^\$(\w+)\s*=\s*(.*)', raw_line)
        if var_match:
            variables[var_match.group(1)] = var_match.group(2).strip()
            continue

        # Sources: source = path
        source_match = re.match(r'^source\s*=\s*(.*)', raw_line)
        if source_match:
            src_path = source_match.group(1).strip()
            if not os.path.isabs(os.path.expanduser(src_path)):
                src_path = os.path.join(os.path.dirname(expanded_path), os.path.expanduser(src_path))
            
            sub_binds, variables = parse_hypr_config(src_path, variables, current_category)
            binds.extend(sub_binds)
            continue

        # Categories: ### Header ### or # Category #
        cat_match = re.match(r'^#+\s*([A-Z][A-Z\s\-]+[^#\s]*)\s*#*', raw_line)
        if cat_match:
            cat_text = cat_match.group(1).strip().replace("-", "").strip()
            if cat_text and len(cat_text) > 2:
                current_category = cat_text
            continue

        # Binds
        bind_match = re.match(r'^(bind[a-z]*)\s*=\s*(.*)', raw_line)
        if bind_match:
            bind_type = bind_match.group(1)
            content = bind_match.group(2)
            parts = [p.strip() for p in content.split(',')]
            if len(parts) < 3:
                continue
            
            has_desc = bind_type in ["bindd", "binded"]
            mod = parts[0]
            key = parts[1]
            description = ""
            dispatcher = ""
            arg = ""

            if has_desc:
                description = parts[2]
                dispatcher = parts[3] if len(parts) > 3 else ""
                arg = ",".join(parts[4:]) if len(parts) > 4 else ""
            else:
                dispatcher = parts[2]
                arg = ",".join(parts[3:]) if len(parts) > 3 else ""

            # Resolve variables
            def resolve_vars(text):
                for var_name, var_val in variables.items():
                    text = text.replace(f"${var_name}", var_val)
                return text

            mod = resolve_vars(mod).replace("+", " + ").strip()
            if mod.endswith("+"): mod = mod[:-1].strip()
            key = resolve_vars(key)
            description = resolve_vars(description)
            arg = resolve_vars(arg)

            binds.append({
                "category": current_category,
                "mod": mod,
                "key": key,
                "description": description,
                "dispatcher": dispatcher,
                "arg": arg
            })

    return binds, variables

if __name__ == "__main__":
    hypr_dir = os.path.expanduser("~/.config/hypr")
    main_config = os.path.join(hypr_dir, "hyprland.conf")
    
    all_binds, _ = parse_hypr_config(main_config)
    
    # Group by category and remove duplicates
    result_map = {}
    seen = set()
    
    for b in all_binds:
        # Avoid exact duplicates
        identifier = f"{b['mod']}|{b['key']}|{b['dispatcher']}|{b['arg']}"
        if identifier in seen:
            continue
        seen.add(identifier)
        
        cat = b['category']
        if cat not in result_map:
            result_map[cat] = []
        result_map[cat].append(b)

    # Convert to list for QML
    final_output = [{"name": name, "binds": items} for name, items in result_map.items()]
    print(json.dumps(final_output, indent=2))
