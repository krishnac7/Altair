#ifndef OPS_HPP_INCLUDED
#define OPS_HPP_INCLUDED

#include <cstdint>

namespace ar
{

namespace op
{

enum class compute_units : uint32_t
{
	BRU = 0,
	AGU = 0,

	LSU = 1,

	ALU = 2,

	VFPU = 3,
	VDIV = 3,
};

struct operation
{
	compute_units compute_unit : 2;
	uint32_t : 30;
};
static_assert(sizeof(operation) == sizeof(uint32_t));

constexpr bool assertOpcodeIndex(operation o, uint32_t index) noexcept
{
	const compute_units compute_unit = o.compute_unit;

	if(index == 0)
	{
		if(compute_unit == compute_units::BRU) // BRU
			return true;
		else if(compute_unit == compute_units::LSU) // LSU
			return true;
		else if(compute_unit == compute_units::ALU) // ALU
			return true;
		else // VFPU/VDIV
			return true;
	}
	else if(index == 1)
	{
		if(compute_unit == compute_units::AGU) // AGU
			return true;
		else if(compute_unit == compute_units::LSU) // LSU
			return true;
		else if(compute_unit == compute_units::ALU) // ALU
			return true;
		else // VFPU
			return true;
	}
	else // 2 or 3
	{
		if(compute_unit == compute_units::ALU) // ALU
			return true;
		else // VFPU
			return false;
	}
}

} // namespace op

} // namespace ar

#endif // OPS_HPP_INCLUDED
