# Decoder for raw scalar values returned by the host.
#
# The WebDriver host returns unquoted values ("hello", "42", "true"), so the
# builtin JSON decoder cannot parse them directly. This module implements the
# `Encoding` protocol for those raw scalars. Only the scalar shapes used by
# `Element.get_property!` and `Browser.execute_js*` are supported.
PropertyDecoder :: [].{

	PropertyState := { raw : Str }

	PropertyError : [BadProperty(Str)]

	ElementProperty :: [Raw].{
		missing_field : ElementProperty, Str -> PropertyError
		missing_field = |_, name| BadProperty("missing field: ${name}")

		parse_str : ElementProperty, PropertyState -> Try({ value : Str, rest : PropertyState }, PropertyError)
		parse_str = |_, state| Ok({ value: state.raw, rest: PropertyState.{ raw: "" } })

		parse_bool : ElementProperty, PropertyState -> Try({ value : Bool, rest : PropertyState }, PropertyError)
		parse_bool = |_, state|
			match state.raw {
				"" => Ok({ value: False, rest: PropertyState.{ raw: "" } })
				"true" => Ok({ value: True, rest: PropertyState.{ raw: "" } })
				"false" => Ok({ value: False, rest: PropertyState.{ raw: "" } })
				other => Err(BadProperty("could not decode \"${other}\" as Bool")),
			}

		parse_u8 : ElementProperty, PropertyState -> Try({ value : U8, rest : PropertyState }, PropertyError)
		parse_u8 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = U8.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as U8"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_i8 : ElementProperty, PropertyState -> Try({ value : I8, rest : PropertyState }, PropertyError)
		parse_i8 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = I8.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as I8"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_u16 : ElementProperty, PropertyState -> Try({ value : U16, rest : PropertyState }, PropertyError)
		parse_u16 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = U16.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as U16"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_i16 : ElementProperty, PropertyState -> Try({ value : I16, rest : PropertyState }, PropertyError)
		parse_i16 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = I16.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as I16"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_u32 : ElementProperty, PropertyState -> Try({ value : U32, rest : PropertyState }, PropertyError)
		parse_u32 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = U32.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as U32"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_i32 : ElementProperty, PropertyState -> Try({ value : I32, rest : PropertyState }, PropertyError)
		parse_i32 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = I32.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as I32"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_u64 : ElementProperty, PropertyState -> Try({ value : U64, rest : PropertyState }, PropertyError)
		parse_u64 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = U64.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as U64"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_i64 : ElementProperty, PropertyState -> Try({ value : I64, rest : PropertyState }, PropertyError)
		parse_i64 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = I64.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as I64"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_u128 : ElementProperty, PropertyState -> Try({ value : U128, rest : PropertyState }, PropertyError)
		parse_u128 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = U128.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as U128"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_i128 : ElementProperty, PropertyState -> Try({ value : I128, rest : PropertyState }, PropertyError)
		parse_i128 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = I128.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as I128"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_dec : ElementProperty, PropertyState -> Try({ value : Dec, rest : PropertyState }, PropertyError)
		parse_dec = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = Dec.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as Dec"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_f32 : ElementProperty, PropertyState -> Try({ value : F32, rest : PropertyState }, PropertyError)
		parse_f32 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = F32.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as F32"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_f64 : ElementProperty, PropertyState -> Try({ value : F64, rest : PropertyState }, PropertyError)
		parse_f64 = |_, state|
			if state.raw.is_empty() {
				Ok({ value: 0, rest: PropertyState.{ raw: "" } })
			} else {
				value = F64.from_str(state.raw).map_err(|_| BadProperty("could not decode \"${state.raw}\" as F64"))?
				Ok({ value, rest: PropertyState.{ raw: "" } })
			}

		parse_null : ElementProperty, PropertyState -> Try(PropertyState, PropertyError)
		parse_null = |_, state|
			if state.raw.is_empty() or state.raw == "null" {
				Ok(PropertyState.{ raw: "" })
			} else {
				Err(BadProperty("could not decode \"${state.raw}\" as Null"))
			}
	}

	## Any scalar type that can be decoded from a raw host value.
	output.Parseable(errs) : where [
		output.parser_for : ElementProperty -> (PropertyState -> Try({ value : output, rest : PropertyState }, errs)),
	]

	## Decode a raw host value into any scalar type.
	parse : Str -> Try(output, PropertyError)
		where [output.Parseable(PropertyError)]
	parse = |raw| {
		Output : output
		parse_output = Output.parser_for(ElementProperty.Raw)
		parsed = parse_output(PropertyState.{ raw })?

		match parsed.rest {
			{ raw: rest } =>
				if rest.is_empty() {
					Ok(parsed.value)
				} else {
					Err(BadProperty("unexpected trailing input: \"${rest}\""))
				}
		}
	}
}
